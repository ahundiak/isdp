/*****************************************************************
*								 *
*	Modifications:						 *
*		a.  January 23, 1989 by Lynn Mettlen--changed	 *
*		    flag in ex$retrieve_module to EX_overwrite	 *
*		    from overwrit.				 *
*		b.  January 24, 1989 by Lynn Mettlen--deleted	 *
*		    ex$save_module in PDUint_checkin.		 *
*		c.  April 4, 1989 by Lynn Mettlen--added check   *
*		    on reference description to make sure there  *
*		    were at least 3 colons, which indicates file *
*		    is a PDM reference file. (PDUreport_attached *
*		d.  7/11/89 lmm close bom_list in act and deact  *
*		e.  9/89 lmm renamed file and removed all but	 *
*		    checkin functions				 *
*		f.  10/89 lmm removed retrieve to PDUreffile and *
*		    introduced global file index		 *
*		    						 *
*****************************************************************/
class implementation COpdu;

#include	<string.h>
#include	<unistd.h>
#include	<PDUint.h>
#include	<PDUintdef.h>
#include	<PDUfile_def.h>
#include	<refdef.h>
#include	<exdef.h>
#include	<exmacros.h>
#include	<expriv.h>
#include	<grio.h>
#include	<griodef.h>
#include	<griomacros.h>
#include	<msdef.h>
#include	<dpmacros.h>
#include	<dp.h>
#include	<dpdef.h>
#include	<igrdef.h>
#include        <grdpbmacros.h>
#include        <PDUuser.h>
#include        <PDUprompt.h>
#include        <MEMerrordef.h>
#include        "DIdef.h"
#include        "DItypedef.h"
#include        "DIprims.h"
#include        "DIglob.h"
#include        "OMtypes.h"
#include        "PDUgrpart.h"
#include        "partmacros.h"
#include        "part.h"
#include        "partdef.h"
#include        "PDUnode.h"
#include        "PDUstorage.h"
#include 	"PDUerror.h"
#include 	"PDUforms.h"
#include 	"PDUform_def.h"


extern IGRint            PDMdebug_on;
extern IGRchar		 PDU_last_file [];
extern struct PDUrefresh *refresh; 
extern struct PDUuser    *user; 
extern IGRint   	 PDU_invis_file_index;	/** 10/89 lmm **/
extern IGRpoint          PDU_origin_point;
extern IGRint            PDUactive_checkin;
extern IGRint            PDM_debug_on;
extern IGRint            PDU_command;
extern MEMptr            PDUchild_dyn_buffer;
extern MEMptr            PDU_child_buffer;
extern MEMptr            PDU_attach_bufr;
extern MEMptr            PDU_attach_buffer;
extern MEMptr            PDU_detach_buffer;
extern MEMptr            PDU_view_buffer;
extern MEMptr            PDU_param_buffer;
extern MEMptr            PDU_file_bufr;
extern MEMptr            PDU_ret_bufr;
extern IGRchar           *PDU_save_filename;
extern IGRchar           *PDU_checkin_file;
extern MEMptr            PDU_dyn_attr_bufr;
extern MEMptr            PDU_dyn_data_bufr;
IGRchar                  *PDU_topdown_flag;
extern struct PDUcat_node *PDU_param_cat_list;
extern int               PDU_dyn_index;
extern short             PDU_is_om_file;
extern Form              PDU_form_id;
extern struct PDUforms   forms;

from GRreffile   import  GRgetdescription;
from GRreffile   import  GRputdescription;

IGRint	PDUint_checkin ()
  {
 struct GRmd_env  mod_env;
 IGRint          msg;
 IGRlong          status = PDM_S_SUCCESS;
 IGRlong          sts = PDM_S_SUCCESS;
 IGRint           index = 0;
 IGRchar          mount_name[40];
 GRobjid          osid = NULL_OBJID;
 OMuword          osnum;
 GRobjid          objid;
 IGRlong          NumberOfBytes, BytesReceived;
 IGRchar          **data_row = NULL;
 IGRchar          *state = NULL;
 IGRchar          *file_data = NULL;
 IGRchar          *file = NULL;
 IGRint           file_col;
 IGRint           row;
 IGRint           save_flag;
 IGRshort         major;
 IGRshort         minor;
 IGRchar          mach_type;
 IGRint           file_type;
 IGRint           count = 0;
 IGRchar          *ptr = NULL;
 IGRchar          active_file[DI_PATH_MAX];
 char              *msg_str = NULL;
 struct PDUpart_node *parametric_ids = NULL;
 struct PDUpart_node *head = NULL;
 IGRchar          **om_data = NULL;
 MEMptr           om_files = NULL;

 extern            IGRint PDU_exit_case;
/*
 IGRlong           ci_enter;
 IGRlong           ci_exit;
 IGRlong           ci_inter;
 IGRlong           call_time();
 IGRdouble           d_enter;
 IGRdouble           d_exit;
 IGRdouble           d_inter;
 IGRdouble           system_time();
*/

  /* mark entry time */
/*
  ci_enter = ci_inter =  call_time();
  d_enter = d_inter =  system_time();
*/

  _pdm_debug("In the function PDUint_checkin", 0);

  PDU_is_om_file = TRUE;
  /* Get active module information */
  NumberOfBytes = sizeof(mod_env);
  status = gr$get_module_env(
                             msg = &msg,
                             sizbuf = &NumberOfBytes,
                             buffer = &mod_env,
                             nret = &BytesReceived
                            );

  sts = PDMvalidate_user_access(
                                "PDMCheck In Part", NULLSTR,
                                refresh->rev_catalog,
                                NULLSTR,
                                refresh->rev_partid,
                                refresh->rev_revision
                               );
  _pdm_status ("PDMvalidate_user_access", sts);

  if (sts != PDM_S_SUCCESS)
    {
    PDUmessage(sts, 's');
    return(sts);
    }

  if ((PDU_command != PDC_M_DEACTIVATE_CHECKIN) &&
      (PDU_command != PDC_M_CREATE_TOP_DOWN))
    {
    /* check to see if the part is checked out */
    status = PDUget_file_status(
                                refresh->rev_catalog,
                                refresh->rev_partid,
                                refresh->rev_revision,
                                &state
                               );
    _pdm_status("PDUget_file_status", status);
    
    if (status != PDM_S_SUCCESS)
      {
      PDUmessage(status, 's');
      return(status);
      }

    if (state != NULL)
      {
      _pdm_debug("file state = <%s>", state);
  
      if ((strcmp(state, "O") != 0) && (strcmp(state, "S") != 0) &&
          (strcmp(state, " ") != 0) && (strcmp(state, "") != 0))
        {
        status = PDM_E_NOTCHECK_OUT;
        PDUmessage(status, 's');
        return(status);
        }
      }

    }

 if (PDU_exit_case == 3)
    goto inactive_checkin;

  /* mark exit time */
/*
  ci_exit = call_time();
  d_exit = system_time();
  sprintf(s,"From enter internal checkin to check file status  %f\n",(ci_exit - ci_inter));
  TIMEdebug(s);
  _TIMEdebug(d_inter,d_exit,"From enter internal checkin to check file status");
*/

  /* mark enter time */
/*
  ci_inter = call_time();
  d_inter = system_time();
*/

  /* call PDM function to retrieve a list of filenames */
  if (PDU_file_bufr)
    {
    MEMclose(&PDU_file_bufr);
    PDU_file_bufr = NULL;
    }
  status = PDMget_filenames(
                            refresh->rev_catalog,
                            refresh->rev_partid,
                            refresh->rev_revision,
                            &PDU_file_bufr
                           );
  _pdm_status("PDMget_filenames", status);

  if ( status != PDM_S_SUCCESS )
    {
    PDUmessage(status, 's');
    MEMclose(&PDU_file_bufr);
    PDU_file_bufr = NULL;
    return(status);
    }

  if ((PDU_file_bufr == NULL) || (PDU_file_bufr->rows == 0))
    {
    status = PDM_I_NO_FILES_FOUND;
    PDUmessage(status, 's');
    return(status);
    }

  status = MEMbuild_array(PDU_file_bufr);
  _pdm_status("MEMbuild_array", status);

  if (status != MEM_S_SUCCESS)
    {
    status = PDM_E_BUILD_BUFFER_ARRAY;
    PDUmessage(status, 's');
    return(status);
    }

  PDUsetup_buffer(PDU_file_bufr, ROW, &data_row);
  PDUget_buffer_col(PDU_file_bufr, "n_cofilename", &file_col);

  /* Open PDU_ret_bufr */
  PDMopen_buffer(12, &PDU_ret_bufr);

  for (row = 0; row < PDU_file_bufr->rows; ++row)
     {
     PDUfill_in_string(
                       &file, 
                       data_row[(PDU_file_bufr->columns * row) + file_col]
                      );
     _pdm_debug("row = %d", row);
     _pdm_debug("filename = <%s>", file);

     /* verify filename for part */
     status = PDUverify_file(file);
     _pdm_status("PDUverify_file", status);

     if (status == PDM_E_FILE_NOT_FOUND)
       {
       status = PDM_E_FILE_NOT_LOCAL;
       PDUfill_in_string(&PDU_save_filename, file);
       _pdm_debug("checkin file does not exist locally", 0);
       PDUmessage(status, 's');
       return(status);
       }

     else
         {
         /* Check to see if part is a macro library */
         if ( (strcmp(refresh->rev_parttype, "M") == 0 ) ||
              (strcmp(refresh->rev_parttype, "m") == 0 ) )
             {
              _pdm_debug("Checking in a macro library", 0);
              return(PDM_S_SUCCESS);
             }

          /* Check to see if file is an OM file */
          save_flag = 0;
          status = ex$is_om_file(
                                 filename = file,
                                 p_major = &major,
                                 p_minor = &minor,
                                 p_mach_type = &mach_type,
                                 p_file_type = &file_type
                                );
          _pdm_status("ex$is_om_file", status);

          if (status)
             {
              _pdm_debug("file <%s> is an OM file", file);

              /* Get child number seed from object space */
              di$give_pathname(
                               osnum = mod_env.md_id.osnum,
                               pathname = active_file 
                              );

              ptr = active_file;
              ++ptr;

              /* Make sure checkin file is not active */
              if (strcmp(ptr, file) == 0)
                 {
                  _pdm_debug("file <%s> must be closed first", ptr);
                  return(PDM_E_OPEN_FILE_NOT_ALLOWED); 
                 }
                    

              /* Construct file mount name */
              strcpy(mount_name, ":");
              strcat(mount_name, file);

              /* Get osnum of invis space */
              status = ex$retrieve_module (
                                           filename = file,
                                           file_no = &index,
                                           ftype = EX_invisible,
                                           flag = EX_read_write,
                                           fstat = EX_default,
                                           type = EX_ACTINV,
                                           mount_name = mount_name,
                                           msg = &msg
                                          );
              _pdm_status ("ex$retrieve_module", status);

              if (!status)
                 {
                  _pdm_debug("ex$retrieve_module failed on <%s>",
                             file);
                  return(PDM_E_OPEN_FILE);
                 }

              /* Open object space */
              status = ex$get_invis_info_by_index (
                                                   index = index,
                                                   mod_osnum = &osnum,
                                                   mod_id = &objid,
                                                   filed_id = &osid
                                                  );
              _pdm_status ("ex$get_invis_info_by_index", status);

              if (!status)
                 {
                  _pdm_debug("ex$get_invis_info_by_index failed on <%s>",
                             file);
                  return(PDM_E_OPEN_FILE);
                 }

              mod_env.md_id.osnum = osnum;
              mod_env.md_id.objid = objid;

              /* Check to see if file is a PDU file */
              if ( PDUis_PDU_file(mod_env) )
                 {
                  /* Malloc file_data */
                  file_data = (IGRchar *)
                               malloc(sizeof(IGRchar) * PDU_ret_bufr->row_size);

                  /* Write file to PDU_ret_bufr */
                  memset(file_data, NULL, PDU_ret_bufr->row_size);
                  sprintf(file_data, "%s\1", file);
                  MEMwrite(PDU_ret_bufr, file_data);

                  /* Remove PDU_DESIGN_FILE stamp "directory", if any */
                  /*status = PDUremove_PDU_file_stamp(mod_env);
                  _pdm_status("PDUremove_PDU_design_file_stamp", status);*/

                  /* Set save_flag */
                  save_flag = 1;
                 }

              /* Close and save object space */
              status = ex$close_module (
                                        index = index,
                                        flag = save_flag | EX_ACTINV,
                                        ftype = EX_invisible
                                       );
              _pdm_status ("ex$close_module", status);
             }

          else
              {
               _pdm_debug("file <%s> is not an OM file", file);
               PDU_is_om_file = FALSE;
              }
         }
     } /* end for loop */

  /* mark exit time */
/*
  ci_exit = call_time();
  d_exit = system_time();
  sprintf(s,"After retrieving and verifying files  %f\n",(ci_exit - ci_inter));
  TIMEdebug(s);
  _TIMEdebug(d_inter,d_exit,"After retrieving and verifying files");
*/

  /* Display list of PDU files, if any */
  if (PDU_ret_bufr->rows >= 1)
     {
      PDU_is_om_file = TRUE;
      _pdm_debug("%d PDU files were found", PDU_ret_bufr->rows);

      if (PDU_ret_bufr->rows == 1)
         {
          *((IGRchar *)strrchr(file_data, '\1')) = '\0';
          PDUfill_in_string(&PDU_checkin_file, file_data);
         }

      else 
          {
           /* Display checkin file form */
           index = -1;
           status = PDUfind_PDU_stamp_files(PDU_ret_bufr, ptr,
                                            &om_files, &mod_env, &index);
           _pdm_status("PDUfind_PDU_stamp_files", status);
           if (status != PDM_S_SUCCESS)
             return(status);
           if (om_files->rows == 1)
             {
             status = MEMbuild_array(om_files);
             _pdm_status("MEMbuild_array", status);
             if (status != MEM_S_SUCCESS)
               return(PDM_E_BUILD_BUFFER_ARRAY);
             om_data = (char **)om_files->data_ptr;
             status = PDUget_buffer_col(om_files, "n_cofilename", &file_col);
             _pdm_status("PDUget_buffer_col", status);
             if (status != PDM_S_SUCCESS)
               return(status);
             PDUfill_in_string(&PDU_checkin_file, om_data[file_col]);
             if (index != -1)
               {
               status = ex$close_module(index = index, flag = 1 | EX_ACTINV,
                                        ftype = EX_invisible);
               _pdm_status("ex$close_module", status);
               }
             }
          else
            {
             if (index != -1)
               {
               status = ex$close_module(index = index, flag = 1 | EX_ACTINV,
                                        ftype = EX_invisible);
               _pdm_status("ex$close_module", status);
               }
           
           status = PDUdisplay_checkin_files();
           _pdm_status("PDUdisplay_checkin_files", status);

           msg_str = (char *)PDUtranslate_message(PDM_I_FILE_DEFASSEM_STRUCT);
           UI_status(msg_str);
           status = WaitForEvent();
           _pdm_status("WaitForEvent", status); 

           if (!status)
              {
               _pdm_debug("checkin form was cancelled", 0);
               return(PDM_E_CMD_CANCELLED);
              }
           }
          }

      if (!PDU_checkin_file)
         {
          _pdm_debug("PDU_checkin_file is NULL", 0);
          return(PDM_E_COMPLETE_PART_CHECKIN);
         }

inactive_checkin:
      
      _pdm_debug("selected checkin file name = <%s>", PDU_checkin_file);

      /* Construct file mount name */
      strcpy(mount_name, ":");
      strcat(mount_name, PDU_checkin_file);

      /* Get osnum of invis space */
      status = ex$retrieve_module (
                                   filename = PDU_checkin_file,
                                   file_no = &index,
                                   ftype = EX_invisible,
                                   flag = EX_read_write,
                                   fstat = EX_default,
                                   type = EX_ACTINV,
                                   mount_name = mount_name,
                                   msg = &msg
                                  );
      _pdm_status ("ex$retrieve_module", status);

      if (!status)
         {
            return(PDM_E_OPEN_FILE); 
         }

      /* Open object space */
      status = ex$get_invis_info_by_index (
                                           index = index,
                                           mod_osnum = &osnum,
                                           mod_id = &objid,
                                           filed_id = &osid
                                          );
      _pdm_status ("ex$get_invis_info_by_index", status);

      if (!status)
         {
          _pdm_debug("ex$get_invis_info_by_index failed on <%s>",
                     PDU_checkin_file);
          return(PDM_E_OPEN_FILE);
         }

      mod_env.md_id.osnum = osnum;
      mod_env.md_id.objid = objid;

      /* Stamp PDU design file with PDU_DESIGN_FILE */
      status = PDUstamp_PDU_design_file(mod_env);
      _pdm_status("PDUstamp_PDU_design_file", status);

      /* Initialize child buffer */
      PDU_child_buffer = NULL;

      /* Check to see if parametric parts exist */
      status = PDUget_all_parametric_ids(
                                         osnum,
                                         &parametric_ids,
                                         &count
                                        );
      _pdm_status("PDUget_all_parametric_ids", status);

      if (count > 0)
         {
          /* Free parametric_ids */
          if (parametric_ids)
             {
              head = parametric_ids;

              while (parametric_ids)
                    {
                     parametric_ids = parametric_ids->next;
                     free(head);
                     head = parametric_ids;
                    }
             }

          /* Load PDU_param_cat_list list */
          status = PDUprepare_param_cats_list(
                                              &mod_env,
                                              &PDU_param_cat_list
                                             );
          _pdm_status("PDUprepare_param_cats_list", status);

          if (status != PDM_S_SUCCESS)
             {
              _pdm_debug("PDUprepare_param_cats_list failed", 0);

              /* Need to close obj space */
              status = ex$close_module (
                                        index = index,
                                        flag = 1 | EX_ACTINV,
                                        ftype = EX_invisible
                                       );
              _pdm_status ("ex$close_module", status);
              return(PDM_E_COMPLETE_PART_CHECKIN);
             }

          /* Initialize parametric assembly buffer */
          PDU_param_buffer = NULL;
          PDUchild_dyn_buffer = NULL;

          /* Initialize PDU_dyn_index */
          PDU_dyn_index = 1;

          /* Load parametric checkin info */
          status = PALchekin(&mod_env);
          _pdm_status("PALcheckin", status);

          if (!status)
             {
              _pdm_debug("PALcheckin failed", 0);

              /* Need to close obj space */
              status = ex$close_module (
                                        index = index,
                                        flag = 1 | EX_ACTINV,
                                        ftype = EX_invisible
                                       );
              _pdm_status ("ex$close_module", status);
              return(PDM_E_COMPLETE_PART_CHECKIN);
             }
         }
        else
          {
          /* Load PDU_param_cat_list list */
          status = PDUprepare_param_cats_list(
                                              &mod_env,
                                              &PDU_param_cat_list
                                             );
          _pdm_status("PDUprepare_param_cats_list", status);

          if (status != PDM_S_SUCCESS)
             {
              _pdm_debug("PDUprepare_param_cats_list failed", 0);

              /* Need to close obj space */
              status = ex$close_module (
                                        index = index,
                                        flag = 1 | EX_ACTINV,
                                        ftype = EX_invisible
                                       );
              _pdm_status ("ex$close_module", status);
              return(PDM_E_COMPLETE_PART_CHECKIN);
             }
           }
      /* Extract part pointer info */
      status = PDUload_child_buffer(
                                    &PDU_child_buffer,
                                    mod_env
                                   );
      if (status != PDM_S_SUCCESS)
         {
          _pdm_debug("PDUload_child_buffer failed", 0);

          /* Need to close obj space */
          status = ex$close_module (
                                    index = index,
                                    flag = 1 | EX_ACTINV,
                                    ftype = EX_invisible
                                   );
          _pdm_status ("ex$close_module", status);
          return(PDM_E_COMPLETE_PART_CHECKIN);
         }

      /* Initialize attach buffer */
      PDU_attach_bufr = NULL;

      /* Extract part attachment info */
      status = PDUload_attach_buffer(
                                     &PDU_attach_bufr,
                                     mod_env
                                    );

      if (status != PDM_S_SUCCESS)
         {
          _pdm_debug("PDUload_attach_buffer failed", 0);

          /* Need to close obj space */
          status = ex$close_module (
                                    index = index,
                                    flag = 1 | EX_ACTINV,
                                    ftype = EX_invisible
                                   );
          _pdm_status ("ex$close_module", status);
          return(PDM_E_COMPLETE_PART_CHECKIN);
         }

      /* Close and initialize PDU_dyn_attr_bufr and PDU_dyn_data_bufr */
      if (PDU_dyn_attr_bufr)
         {
          MEMclose(&PDU_dyn_attr_bufr);
          PDU_dyn_attr_bufr = NULL;
         }

      if (PDU_dyn_data_bufr)
         {
          MEMclose(&PDU_dyn_data_bufr);
          PDU_dyn_data_bufr = NULL;
         }

      /* Extarct dynamic attributes */
      status = PDUload_dynamic_attrs(
                                     &mod_env,
                                     &PDU_dyn_attr_bufr,
                                     &PDU_dyn_data_bufr
                                    );
      _pdm_status("PDUload_dynamic_attrs", status);

      if (status != PDM_S_SUCCESS)
         {
          _pdm_debug("PDUload_dynamic_attrs failed", 0);

          /* Need to close obj space */
          status = ex$close_module (
                                    index = index,
                                    flag = 1 | EX_ACTINV,
                                    ftype = EX_invisible
                                   );
          _pdm_status ("ex$close_module", status);
          return(PDM_E_COMPLETE_PART_CHECKIN);
         }

      /* Initialize view buffer */
      PDU_view_buffer = NULL;

      /* Extract view info */
      status = PDUload_view_info(
                                 mod_env.md_id.objid,
                                 mod_env.md_id.osnum,
                                 &PDU_view_buffer
                                );
      _pdm_status("PDUload_view_info", status);

      /* Need to close and save obj space */
      sts = ex$close_module (
                             index = index,
                             flag = 1 | EX_ACTINV,
                             ftype = EX_invisible
                            );

      if ( (status != PDM_S_SUCCESS) && (status != PDM_I_ORIGIN_NOT_FOUND) )
         {
          _pdm_debug("PDUload_view_info failed", 0);
          return(PDM_E_COMPLETE_PART_CHECKIN);
         }

      if (status == PDM_I_ORIGIN_NOT_FOUND)
         {
          _pdm_debug("No origins were defined in checkin file", 0);
         }

      status = PDM_S_SUCCESS;

      if (PDM_debug_on)
         {
          MEMprint_buffer("child buffer", PDU_child_buffer, PDU_DEBUG_FILE);
          MEMprint_buffer("attach buffer", PDU_attach_bufr, PDU_DEBUG_FILE);
          MEMprint_buffer("view buffer", PDU_view_buffer, PDU_DEBUG_FILE);
          MEMprint_buffer("dyn attr buffer", PDU_dyn_attr_bufr, PDU_DEBUG_FILE);
          MEMprint_buffers("dyn data buffer",PDU_dyn_data_bufr, PDU_DEBUG_FILE);
          MEMprint_buffers("dyn data param buffer",
                            PDUchild_dyn_buffer, PDU_DEBUG_FILE);
         }
     }

  else
      {
       _pdm_debug("no PDU file(s) were found", 0);

       /* Close PDU_ret_bufr */
       if (PDU_ret_bufr)
         {
         MEMclose(&PDU_ret_bufr);
         PDU_ret_bufr = NULL;
         }

       status = PDM_S_SUCCESS;
      }

  /* design file gets left open when part is checked in from revise assembly */
  if ((PDU_form_id == forms.rev_assy_form_id) && (PDU_form_id != 0) &&
      (PDU_checkin_file) && (strcmp(refresh->rev_parttype, "M") != 0) &&
                            (strcmp(refresh->rev_parttype, "m") != 0))
    {
    /* make sure files are not open */
    sts = PDUis_file_open(PDU_checkin_file);
    _pdm_status("PDUis_file_open", sts);
  
    if (sts)
      {
      _pdm_debug("closing file", 0);
      /* Need to close obj space */
      sts = ex$close_module (
                                index = index,
                                flag = 1 | EX_ACTINV,
                                ftype = EX_invisible
                               );
      _pdm_status ("ex$close_module", sts);
      }
    }

  /* mark total time */
/*
  ci_exit = call_time();
  d_exit = system_time();
  sprintf(s,"total time in internal checkin  %f\n",(ci_exit - ci_enter));
  TIMEdebug(s);
  _TIMEdebug(d_enter,d_exit,"Total time in internal checkin");
*/

  /* Free variables */
  if (file_data)
     free(file_data);

  if (file)
     free(file);

  if (PDU_checkin_file)
     {
      free(PDU_checkin_file);
      PDU_checkin_file = NULL;
     }

  return (status);
  }

IGRint	PDUextract_reffile_desc()
  {
  IGRint        status = OM_S_SUCCESS;
  IGRlong	msg = MSSUCC;
  IGRint        ref_count = 0, i;
  IGRchar	ref_descr[100], *s;
  IGRshort	flag = 0;	
  struct PDUid  ref_mgr;
  OM_S_CHANSELECT  refs;
  OMuword       osnum;
  OM_S_OBJID    osid;

  _pdm_debug("In the function PDUextract_reffile_desc", 0 );

  /* get active module info */
  status = ex$get_cur_mod ( id = &osid, osnum = &osnum );
  _pdm_status ("ex$get_cur_mod", status);

  ref_mgr.osnum = osnum;

  /* get objid of reference file manager in object space */
  status =  ex$get_objid_from_NOD ( NODname = "IGENOD",
				    objname = REFERENCE_FILE_MANAGER,
				    pobjid = &(ref_mgr.objid),
				    mod_osnum = ref_mgr.osnum );
  _pdm_rstatus ("ex$get_objid_from_NOD", status);

  if ( 1&status )
     {
     _pdm_debug ("ref mgr objid =  %d", ref_mgr.objid);

     status = om$make_chanselect ( channame = "Super_rfmgr.mgr",
				   p_chanselect = &refs);
     _pdm_status ("om$make_chanselect", status);

     if ( 1&status )
	{
	/* get count of reference file attachments */
	status = om$get_channel_count ( objid = ref_mgr.objid,
				      osnum = ref_mgr.osnum,
				      p_chanselect = &refs,
				      count = (OMuint *)&ref_count );
	_pdm_status ("om$get_channel_count", status);

	if ( 1&status )
	   {
	   if ( ref_count > 0 )
	      {
	      _pdm_debug ("active file had %d reference file(s) attached",
                          ref_count );

	      for ( i = 0; i < ref_count; ++i )
		  {
		     status = om$send( msg = message GRreffile.GRgetdescription
				     ( &msg, &flag, ref_descr ),
					senderid = ref_mgr.objid,
					p_chanselect = &refs,
					targetos = osnum,
					from = i, to = i );
		     _pdm_status2 ("GRreffile.GRgetdescription", status, msg);
		     _pdm_debug ("reffile description = %s", ref_descr );

		     if ( (1&status) )
			{
                        /* load description info into refresh area */
                        s = strtok(ref_descr, ":");
                        s = strtok(0,":");
                        PDUfill_in_string(&refresh->rev_catalog, s);
                        _pdm_debug("extracted catalog = <%s>",
                                   refresh->rev_catalog);

                        s = strtok(0,":");
                        PDUfill_in_string(&refresh->rev_partid, s);
                        _pdm_debug("extracted part id = <%s>",
                                   refresh->rev_partid);

                        s = strtok(0,":");
                        PDUfill_in_string(&refresh->rev_revision, s);
                        _pdm_debug("extracted revision = <%s>",
                                   refresh->rev_revision);
			}
                    else
                        {
                        _pdm_debug("GRreffile.GRgetdescription failed",0);
                        return (status);
                        }

              } /* end for loop */

            } /* end count > 0 */

          else
            {
	     _pdm_debug ("checkin file had no reference files attached", 0 );
             return (status);
            }
       }  
  else
       {
        _pdm_debug("om$get_channel_count failed", 0);
        return (status);
       }
   }
 
 else
    {
    _pdm_debug("om$make_chansel failed",0);
    return (status);
    }
 
  } 
 status = PDM_S_SUCCESS;

  return (status);
  }

/*
 * This function updates the attach info in the PDU design file, if any.
 */
IGRint   PDUfind_PDU_design_file(file_bufr, attach_info_bufr)
  MEMptr     file_bufr;
  MEMptr     attach_info_bufr;
  {
   IGRlong   status = PDM_S_SUCCESS;
   IGRint   msg;
   struct    GRmd_env  mod_env;
   IGRchar   **data_row = NULL;
   IGRint    file_col;
   IGRint    index = 0;
   IGRchar   mount_name[40];
   IGRshort  major;
   IGRshort  minor;
   GRobjid   objid;
   IGRchar   mach_type;
   GRobjid   osid = NULL_OBJID;
   OMuword   osnum;
   IGRint    row;
   IGRint    count = 0;
   char   stamp_path[DI_PATH_MAX];
   IGRchar   *file = NULL;
   IGRint    file_type;
   IGRlong   NumberOfBytes, BytesReceived;


   _pdm_debug("In the PDUfind_PDU_design_file function", 0);

   if ( (attach_info_bufr == NULL) || (attach_info_bufr->rows <= 0) )
      {
       _pdm_debug("no attach info found to update", 0);
       return(PDM_S_SUCCESS);
      }

   /* Process file buffer */
    if ((file_bufr == NULL) || (file_bufr->rows == 0))
       {
        status = PDM_I_NO_FILES_FOUND;
        PDUmessage(status, 's');
        return(status);
       }

   if (PDM_debug_on)
      MEMprint_buffer("files buffer", file_bufr, PDU_DEBUG_FILE);

   status = MEMbuild_array(file_bufr);
   _pdm_status("MEMbuild_array", status);

   if (status != MEM_S_SUCCESS)
      {
       status = PDM_E_BUILD_BUFFER_ARRAY;
       PDUmessage(status, 's');
       return(status);
      }

   PDUsetup_buffer(file_bufr, ROW, &data_row);
   PDUget_buffer_col(file_bufr, "n_cofilename", &file_col);

   _pdm_debug("extracting active module information", 0);

   /* Get active module information */
   NumberOfBytes = sizeof(mod_env);
   status = gr$get_module_env(
                              msg = &msg,
                              sizbuf = &NumberOfBytes,
                              buffer = &mod_env,
                              nret = &BytesReceived
                             );

   /* Check to see if checkout file exists locally */
   for (row = 0; row < file_bufr->rows; ++row)
       {
        PDUfill_in_string(&file,
                        data_row[(file_bufr->columns * row) + file_col]);

        _pdm_debug("checkout filename = <%s>", file);

        /* Verify filename for part */
        status = PDUverify_file(file);
        _pdm_status("PDUverify_file", status);

        if (status == PDM_E_FILE_NOT_FOUND)
           {
            status = PDM_E_FILE_NOT_LOCAL;
            _pdm_debug("SEVERE error: <%s> does not exist locally", file);

            PDUmessage(status, 's');
            return(status);
           }

        /* Check to see if file is an OM file */
        status = ex$is_om_file(
                               filename = file,
                               p_major = &major,
                               p_minor = &minor,
                               p_mach_type = &mach_type,
                               p_file_type = &file_type
                              );
        _pdm_status("ex$is_om_file", status);

        if (status)
           {
            _pdm_debug("file <%s> is an OM file", file);

            /* Construct file mount name */
            strcpy(mount_name, ":");
            strcat(mount_name, file);

            /* Get osnum of invis space */
            status = ex$retrieve_module (

                                         filename = file,
                                         file_no = &index,
                                         ftype = EX_invisible,
                                         flag = EX_read_write,
                                         fstat = EX_default,
                                         type = EX_ACTINV,
                                         mount_name = mount_name,
                                         msg = &msg
                                        );
            _pdm_status ("ex$retrieve_module", status);

            if (!status)
               {
                  _pdm_debug("ex$retrieve_module failed on <%s>", file);
                  return(PDM_E_OPEN_FILE);
               }

            /* Open object space */
            status = ex$get_invis_info_by_index (
                                                 index = index,
                                                 mod_osnum = &osnum,
                                                 mod_id = &objid,
                                                 filed_id = &osid
                                                );
            _pdm_status ("ex$get_invis_info_by_index", status);

            if (!status)
               {
                _pdm_debug("ex$get_invis_info_by_index failed on <%s>",
                           file);
                return(PDM_E_OPEN_FILE);
               }

            mod_env.md_id.osnum = osnum;
            mod_env.md_id.objid = objid;

            /* Construct path to <filename>:PDU_DESIGN_FILE directory */
            di$give_pathname(
                             osnum = osnum,
                             pathname = stamp_path
                            );

            strcat(stamp_path, ":PDU_DESIGN_FILE");

            /* Check to see if file is a PDU design file */
            status = di$ls(regexp = stamp_path, ptr = &count);
            _pdm_status("di$ls", status);

            if ( (status == DIR_S_SUCCESS) && (count > 0) )
               {
                /* Update attach info in the checkout file */
                status = PDUupdate_attach_info(mod_env, attach_info_bufr);
                _pdm_status("PDUupdate_attach_info", status);

                /* Close and save PDU design file */
                status = ex$close_module (
                                          index = index,
                                          flag = 1 | EX_ACTINV,
                                          ftype = EX_invisible
                                         );
                _pdm_status ("ex$close_module", status);

                break;
               }

            /* Close object file */
            status = ex$close_module (
                                      index = index,
                                      flag = 0 | EX_ACTINV,
                                      ftype = EX_invisible
                                     );
            _pdm_status ("ex$close_module", status);
           }

     } /* end for loop */

   /* Free variables */
   if (file)
      free(file);
   
   return(PDM_S_SUCCESS);
  }

IGRint PDUget_child_attach_bufrs(
                                 catalog,
                                 number,
                                 revision,
                                 attach_bufr,
                                 param_cat_list
                                )

IGRchar *catalog;
IGRchar *number;
IGRchar *revision;
MEMptr  *attach_bufr;
struct  PDUcat_node **param_cat_list;

{
 IGRint           msg;
 IGRshort         major;
 IGRshort         minor;
 IGRchar          mach_type;
 IGRint           file_type;
 IGRlong          status = PDM_S_SUCCESS;
 IGRshort         file_found = FALSE;
 MEMptr           file_bufr = NULL;
 IGRchar          stamp_path[DI_PATH_MAX];
 IGRchar          active_file[DI_PATH_MAX];
 IGRchar          *ptr = NULL;
 IGRint           file_col;
 IGRint           index = 0;
 GRobjid          objid;
 IGRchar          mount_name[40];
 OMuword          osnum;
 GRobjid          osid = NULL_OBJID;
 IGRint           row;
 IGRint           count = 0;
 IGRchar          *file = NULL;
 struct           GRmd_env  mod_env;
 IGRchar          **data_row = NULL;
 IGRlong          NumberOfBytes, BytesReceived;


 _pdm_debug("In the PDUget_child_attach_bufr function", 0);

 /* Get part files */
 status = PDMget_filenames(
                           catalog,
                           number,
                           revision,
                           &file_bufr
                          );
 _pdm_status("PDMget_filenames", status);

 if ( status != PDM_S_SUCCESS )
    {
     _pdm_debug("PDMget_filenames failed", 0);
     return(status);
    }

 if ((file_bufr == NULL) || (file_bufr->rows == 0))
    {
     status = PDM_I_NO_FILES_FOUND;
     PDUmessage(status, 's');
     return(status);
    }

 status = MEMbuild_array(file_bufr);
 _pdm_status("MEMbuild_array", status);

 if (status != MEM_S_SUCCESS)
    {
     status = PDM_E_BUILD_BUFFER_ARRAY;
     PDUmessage(status, 's');
     return(status);
    }

 PDUsetup_buffer(file_bufr, ROW, &data_row);
 PDUget_buffer_col(file_bufr, "n_cofilename", &file_col);

    
 /* Get active module information */
 NumberOfBytes = sizeof(mod_env);
 status = gr$get_module_env(
                            msg = &msg,
                            sizbuf = &NumberOfBytes,
                            buffer = &mod_env,
                            nret = &BytesReceived
                           );

 for (row = 0; row < file_bufr->rows; ++row)
     {
     PDUfill_in_string(
                       &file, 
                       data_row[(file_bufr->columns * row) + file_col]
                      );

     _pdm_debug("filename = <%s>", file);

     /* verify filename for part */
     status = PDUverify_file(file);
     _pdm_status("PDUverify_file", status);

     if (status == PDM_E_FILE_NOT_FOUND)
       {
       status = PDM_E_FILE_NOT_LOCAL;
       _pdm_debug("SEVERE error: checkout file <%s> does not exist locally", 
                  file);
       PDUmessage(status, 's');
       return(status);
       }

     else if ( (strcmp(refresh->rev_parttype, "M") == 0) || 
               (strcmp(refresh->rev_parttype, "m") == 0) )
            {
             _pdm_debug("Encountered a macro library", 0);
            }

     else
         {
          /* Check to see if file is an OM file */
          status = ex$is_om_file(
                                 filename = file,
                                 p_major = &major,
                                 p_minor = &minor,
                                 p_mach_type = &mach_type,
                                 p_file_type = &file_type
                                );
          _pdm_status("ex$is_om_file", status);

          if (status)
             {
              _pdm_debug("file <%s> is an OM file", file);

              /* Get active file path */
              di$give_pathname(
                               osnum = mod_env.md_id.osnum,
                               pathname = active_file
                              );

              ptr = active_file;
              ++ptr;

              /* Make sure checkin file is not active */
              if (strcmp(ptr, file) == 0)
                 {
                  _pdm_debug("file <%s> must be closed first", ptr);
                  return(PDM_E_OPEN_FILE_NOT_ALLOWED);
                 }

              /* Construct file mount name */
              strcpy(mount_name, ":");
              strcat(mount_name, file);

              /* Get osnum of invis space */
              status = ex$retrieve_module (
                                           filename = file,
                                           file_no = &index,
                                           ftype = EX_invisible,
                                           flag = EX_read_write,
                                           fstat = EX_default,
                                           type = EX_ACTINV,
                                           mount_name = mount_name,
                                           msg = &msg
                                          );
              _pdm_status ("ex$retrieve_module", status);

              if (!status)
                 {
                    _pdm_debug("ex$retrieve_module failed on <%s>",
                             file); 
                    return(PDM_E_OPEN_FILE);
                 }

              /* Open object space */
              status = ex$get_invis_info_by_index (
                                                   index = index,
                                                   mod_osnum = &osnum,
                                                   mod_id = &objid,
                                                   filed_id = &osid
                                                  );
              _pdm_status ("ex$get_invis_info_by_index", status);

              if (!status)
                 {
                  _pdm_debug("ex$get_invis_info_by_index failed on <%s>",
                             file);
                  return(PDM_E_OPEN_FILE);
                 }

              mod_env.md_id.osnum = osnum;
              mod_env.md_id.objid = objid;

              /* Construct path to <filename>:PDU_DESIGN_FILE directory */
              di$give_pathname(
                               osnum = osnum,
                               pathname = stamp_path
                              );

              strcat(stamp_path, ":PDU_DESIGN_FILE");

              /* Check to see if file is a PDU design file */
              status = di$ls(regexp = stamp_path, ptr = &count);
              _pdm_status("di$ls", status);
  
              if ( (status == DIR_S_SUCCESS) && (count > 0) )
                 {
                  _pdm_debug("<%s> is a PDU design file", file);

                  /* Load param_cat_list list */
                  status = PDUprepare_param_cats_list(
                                                      &mod_env,
                                                      param_cat_list
                                                     );
                  _pdm_status("PDUprepare_param_cats_list", status);

                  if (status != PDM_S_SUCCESS)
                     {
                      _pdm_debug("PDUprepare_param_cats_list failed", 0);

                      /* Need to close obj space */
                      status = ex$close_module (
                                                index = index,
                                                flag = 0 | EX_ACTINV,
                                                ftype = EX_invisible
                                               );
                      _pdm_status ("ex$close_module", status);
                      return(status);
                     }

                  /* Load delete local files buffer */
                  status = PDUload_delete_buffer(
                                                 &mod_env,
                                                 -1,
                                                 attach_bufr
                                                );
                  _pdm_status("PDUload_delete_buffer", status);

                  if (status != PDM_S_SUCCESS)
                     {
                      _pdm_debug("PDUload_delete_buffer failed", 0);

                      /* Need to close obj space */
                      status = ex$close_module (
                                                index = index,
                                                flag = 0 | EX_ACTINV,
                                                ftype = EX_invisible
                                               );
                      _pdm_status ("ex$close_module", status);
                      return(status);
                     }
                 
                  file_found = TRUE;
                 }

              /* Close and save object space */
              status = ex$close_module (
                                        index = index,
                                        flag = 0 | EX_ACTINV,
                                        ftype = EX_invisible
                                       );
              _pdm_status ("ex$close_module", status);

              if (file_found)
                 {
                  status = PDM_S_SUCCESS;
                  break;
                 }

              else
                  {
                   _pdm_debug("<%s> is not a PDU design file", file);
                   status = PDM_S_SUCCESS;
                  }
             }

          else
              {
               _pdm_debug("file <%s> is not an OM file", file);
               status = PDM_S_SUCCESS;
              }
         } 

     } /* end for loop */

  /* Free variables */
  if (file)
     free(file);

  if (file_bufr)
     MEMclose(&file_bufr);

  return(status);
 }

IGRint PDUload_dynamic_attrs(
                             mod_env,       /* INPUT */
                             dyn_attr_bufr, /* INPUT */
                             dyn_data_bufr  /* INPUT */
                            )
 struct GRmd_env         *mod_env;
 MEMptr                  *dyn_attr_bufr;
 MEMptr                  *dyn_data_bufr;
{
 IGRlong                     status = PDM_S_SUCCESS;
 struct   PDUpart_node       *part_ids = NULL;
 struct   PDUpart_node       *parametric_ids = NULL;
 struct   PDUpart_dyn_node   *parts_dyn_attrs_list = NULL;
 struct   PDUpart_dyn_node   *head = NULL;
 IGRint                      count1 = 0;
 IGRint                      count2 = 0;
 IGRchar                     *row = NULL;
 IGRshort                    parts_type;
 MEMptr                      temp_bufr = NULL;


 _pdm_debug("In the PDUload_dynamic_attrs function", 0);


 /* Get all PDU GRpart ids */
 status = PDUget_all_GRpart_ids(
                                mod_env->md_id.osnum,
                                &part_ids,
                                &count1
                               );
 _pdm_status("PDUget_all_GRpart_ids", status);

 /* Get all parametric parts */
 status = PDUget_all_parametric_ids(
                                    mod_env->md_id.osnum,
                                    &parametric_ids,
                                    &count2
                                   );
 _pdm_status("PDUget_all_parametric_ids", status);

 /* Process parametric parts dynamic attributes */
 if (count2 > 0)
    {
     parts_type = 1;
     status = PDUprocess_part_dyn_attrs(
                                        mod_env,
                                        parametric_ids,
                                        &parts_dyn_attrs_list,
                                        parts_type
                                       );
     _pdm_status("PDUprocess_part_dyn_attrs", status);

     if (status != PDM_S_SUCCESS)
        {
         _pdm_debug("PDUprocess_part_dyn_attrs failed", 0);
         return(status);
        }
    }

 /* Process regular parts dynamic attributes */
 if (count1 > 0)
    {
     parts_type = 0;
     status = PDUprocess_part_dyn_attrs(
                                        mod_env,
                                        part_ids,
                                        &parts_dyn_attrs_list,
                                        parts_type
                                       );
     _pdm_status("PDUprocess_part_dyn_attrs", status);

     if (status != PDM_S_SUCCESS)
        {
         _pdm_debug("PDUprocess_part_dyn_attrs failed", 0);
         return(status);
        }
    }
   
 /* Load dyn_attr_bufr and dyn_data_bufr buffers */
 head = parts_dyn_attrs_list;

 if (head)
    {
     /* Format dyn_attr_bufr */
     status = PDMopen_buffer(
                             8,
                             dyn_attr_bufr
                            );
     if (status != PDM_S_SUCCESS)
        {
         _pdm_debug("failure in PDUformat_dyn_buffer", 0);

         /* Free parts_dyn_attrs_list list */
         while (parts_dyn_attrs_list)
               {
                parts_dyn_attrs_list = parts_dyn_attrs_list->next;

                /* Free up node */
                MEMclose(&(head->data_buffer));
                free(head->catalog);
                free(head);

                head = parts_dyn_attrs_list;
               }

         return(status);
        }

     /* Allocate space for row */
     row = (IGRchar *) malloc ((*dyn_attr_bufr)->row_size * sizeof(IGRchar));

     while (head)
           {
            memset(row, NULL, (*dyn_attr_bufr)->row_size);

            /* Write part catalog name to dyn_attr_bufr */
            sprintf(row, "%s\1", head->catalog);

            status = MEMwrite(*dyn_attr_bufr, row);
           
            if (status != MEM_S_SUCCESS)
               {
                _pdm_debug("failed to write to dyn_attr_bufr", 0);

                /* Free parts_dyn_attrs_list list */
                head = parts_dyn_attrs_list;
                while (parts_dyn_attrs_list)
                      {
                       parts_dyn_attrs_list = parts_dyn_attrs_list->next;

                       /* Free up node */
                       MEMclose(&(head->data_buffer));
                       free(head->catalog);
                       free(head);

                       head = parts_dyn_attrs_list;
                      }

                return(PDM_E_WRITE_ROW);
               }

            /* If first node, copy head->data_buffer to dyn_data_bufr */
            if (head == parts_dyn_attrs_list)
               {
                /* Copy data buffer to first node dyn_data_bufr */
                 MEMsplit_copy_buffer(
                                      head->data_buffer,
                                      dyn_data_bufr,
                                      0
                                     );
               }

            else
                {
                 /* Copy data buffer to dyn_data_bufr */
                 MEMsplit_copy_buffer(
                                      head->data_buffer,
                                      &temp_bufr,
                                      0
                                     );

                 /* Append temp_bufr to dyn_data_bufr */
                 status = MEMappend(temp_bufr, *dyn_data_bufr);

                 if (status != MEM_S_SUCCESS)
                    {
                     _pdm_debug("MEMappend failed", 0);

                     /* Free parts_dyn_attrs_list list */
                     head = parts_dyn_attrs_list;
                     while (parts_dyn_attrs_list)
                           {
                            parts_dyn_attrs_list = parts_dyn_attrs_list->next;

                            /* Free up node */
                            MEMclose(&(head->data_buffer));
                            free(head->catalog);
                            free(head);

                            head = parts_dyn_attrs_list;
                           }

                     return(PDM_E_APPEND_BUFFER);
                    }
                }

            /* Process next node */
            head = head->next;

           } /* end while loop */

     /* Free parts_dyn_attrs_list list */
     head = parts_dyn_attrs_list;
     while (parts_dyn_attrs_list)
           {
            parts_dyn_attrs_list = parts_dyn_attrs_list->next;

            /* Free up node */
            MEMclose(&(head->data_buffer));
            free(head->catalog);
            free(head);

            head = parts_dyn_attrs_list;
           }

     /* Free variables */
     if (row)
        free(row);

     /* Close temp_bufr */
     if (temp_bufr)
        {
        MEMclose(&temp_bufr);
        temp_bufr = NULL;
        }
    }
 
 return(PDM_S_SUCCESS);
}

IGRint PDUprocess_part_dyn_attrs(
                                 mod_env,
                                 part_ids,
                                 parts_dyn_attrs_list,
                                 parts_type
                                )
 struct  GRmd_env           *mod_env; 
 struct  PDUpart_node       *part_ids;
 struct  PDUpart_dyn_node   **parts_dyn_attrs_list;
 IGRshort                   parts_type;
{
 IGRlong               status = PDM_S_SUCCESS;
 IGRlong               msg;
 IGRchar               catalog[MAX_VALUE];
 IGRchar               number[MAX_VALUE];
 IGRchar               revision[MAX_VALUE];
 IGRchar               child_no[MAX_VALUE];
 IGRchar               attr_value[MAX_VALUE];
 IGRchar               **attr_names;
 IGRchar               **data_types;
 IGRchar               *row = NULL;
 IGRchar               *params[1];
 IGRchar               **param_vals = NULL;
 IGRchar               path[DI_PATH_MAX];
 IGRint                type;
 IGRint                index = 0;
 IGRint                i;
 IGRshort              catalog_found;
 MEMptr                data_buffer = NULL;
 struct  PDUpart_node  *head = NULL;
 struct  PDUpart_dyn_node *top = NULL;
 struct  PDUpart_dyn_node *temp = NULL;
 struct  PDUpart_dyn_node *tail = NULL;


 _pdm_debug("In the PDUprocess_part_dyn_attrs function", 0);

 if (parts_type)
    {
     /* Process parametric parts */
     
     head = part_ids;

     while (head)
           {
            /* Extract catalog from part */
            params[0] = "n_catalogname";
            status = get_parameter_values(
                                          &(head->part_id),
                                          params,
                                          1,
                                          &param_vals
                                         );
            if (!status)
               {
                _pdm_debug("get_parameter_values failed", 0);

                return(status);
               }

            strcpy(catalog, param_vals[0]);

            /* Check to see if part dyn attrs have already been processed */
            top = *parts_dyn_attrs_list;
            catalog_found = FALSE;

            while (top)
                  {
                   if (strcmp(top->catalog, catalog) == 0)
                      {
                       catalog_found = TRUE;
                       break;
                      }

                   /* Process next node */
                   top = top->next;

                  } /* end while loop */ 

            if (catalog_found)
               {
                _pdm_debug("catalog <%s> found", catalog);

                /* Load dyn attrs to data buffer */
                MEMbuild_array(top->data_buffer);
                attr_names = (IGRchar **) (top->data_buffer)->column_ptr;
                row = (IGRchar *) malloc 
                               ((top->data_buffer)->row_size * sizeof(IGRchar));
                memset(row, NULL, (top->data_buffer)->row_size);
                index = 0;

                /* Extract part child no */
                params[0] = "serial_no";
                status = get_parameter_values(
                                              &(head->part_id),
                                              params,
                                              1,
                                              &param_vals
                                             );
                if (!status)
                   {
                    _pdm_debug("get_parameter_values failed", 0);
    
                    return(status);
                   }

                strcpy(child_no, param_vals[0]);

                /* Write child no to row */
                PDUadd_buffer_string(
                                     row,
                                     &index,
                                     child_no
                                    );

                /* Write a null value for pdcno column */
                PDUadd_buffer_string(
                                     row,
                                     &index,
                                     ""
                                    );

                /* Write dyn attrs values to row */
                for (i = 2; i < (top->data_buffer)->columns; ++i)
                    {
                     /* Extract dyn attr value */
                     params[0] = attr_names[i];
                     status = get_parameter_values(
                                                   &(head->part_id),
                                                   params,
                                                   1,
                                                   &param_vals
                                                  );
                     if (!status)
                        {
                         /* Extract part usage id */
                         params[0] = "p_usageid";
                         status = get_parameter_values(
                                                       &(head->part_id),
                                                       params,
                                                       1,
                                                       &param_vals
                                                      );
                         if (!status)
                            {
                             _pdm_debug("get_parameter_values failed", 0);

                             return(status);
                            }

                         /* Get the path to external dyn. attrs. */
                         di$give_pathname(
                                          osnum = head->part_id.osnum,
                                          pathname = path
                                         );

                         strcat(path, ":PDU:macro_parts:");
                         strcat(path, param_vals[0]);

                         _pdm_debug("external attr. full path = <%s>", path);

                         /* Extract external attr. value */
                         status = PDUevaluate_exp(
                                                  path,
                                                  attr_names[i],
                                                  &param_vals[0]
                                                 );
                         _pdm_status("PDUevaluate_exp", status);

                         if (status != PDM_S_SUCCESS)
                            {
                             _pdm_debug("<%s> must be a new attribute",
                                         attr_names[i]);
                             param_vals[0] = NULL;
                             PDUfill_in_string(&param_vals[0], "");
                            }
                        }

                     strcpy(attr_value, param_vals[0]);

                     /* Write dyn attr value to row */
                     PDUadd_buffer_string(
                                          row,
                                          &index,
                                          attr_value
                                         );
                    } /* end for loop */

                /* Write row into data buffer */
                status = MEMwrite(top->data_buffer, row);

                if (status != MEM_S_SUCCESS)
                   {
                    _pdm_debug("MEMwrite failed", 0);
                    return(PDM_E_WRITE_ROW);
                   }
               }

             else
                 {
                  _pdm_debug("catalog <%s> not found", catalog);

                  /* Extract part number */
                  params[0] = "n_itemname";
                  status = get_parameter_values(
                                                &(head->part_id),
                                                params,
                                                1,
                                                &param_vals
                                               );
                  if (!status)
                     {
                      _pdm_debug("get_parameter_values failed", 0);

                      return(status);
                     }

                  strcpy(number, param_vals[0]);

                  /* Extract part revision */
                  params[0] = "n_itemrev";
                  status = get_parameter_values(
                                                &(head->part_id),
                                                params,
                                                1,
                                                &param_vals
                                               );
                  if (!status)
                     {
                      _pdm_debug("get_parameter_values failed", 0);

                      return(status);
                     }

                  strcpy(revision, param_vals[0]);

                  /* Check to see if part has any dynamic attrs */
                  status = PDMget_dyn_attr_names(
                                                 catalog,
                                                 number,
                                                 revision,
                                                 &data_buffer
                                                );

                  if (status != PDM_S_SUCCESS)
                     {
                      if (status == PDM_E_UNKNOWN_TABLE)
                         {
                          _pdm_debug("dynamic attrs do not exist for part <%s>",
                                 number);
                          return(PDM_S_SUCCESS);
                         }

                      _pdm_debug("PDMget_dyn_attr_names failed", 0);
                      return(status);
                     }

                  if (data_buffer == NULL)
                     {
                      _pdm_debug("dynamic attrs do not exist for part <%s>",
                                 number);
                      return(PDM_S_SUCCESS);
                     }

                  /* Load dyn attrs to data buffer */
                  MEMbuild_array(data_buffer);
                  attr_names = (IGRchar **) data_buffer->column_ptr;
                  row = (IGRchar *) malloc
                                   (data_buffer->row_size * sizeof(IGRchar));
                  memset(row, NULL, data_buffer->row_size);
                  index = 0;

                  /* Extract part child no */
                  params[0] = "serial_no";
                  status = get_parameter_values(
                                                &(head->part_id),
                                                params,
                                                1,
                                                &param_vals
                                               );
                  if (!status)
                     {
                      _pdm_debug("get_parameter_values failed", 0);

                      return(status);
                     }

                  strcpy(child_no, param_vals[0]);

                  /* Write child no to row */
                  PDUadd_buffer_string(
                                       row,
                                       &index,
                                       child_no
                                      );

                  /* Write a null value for pdcno column */
                  PDUadd_buffer_string(
                                       row,
                                       &index,
                                       ""
                                      );

                  /* Write dyn attrs values to row */
                  for (i = 2; i < data_buffer->columns; ++i)
                      {
                       /* Extract dyn attr value */
                       params[0] = attr_names[i];
                       status = get_parameter_values(
                                                     &(head->part_id),
                                                     params,
                                                     1,
                                                     &param_vals
                                                    );
                       if (!status)
                          {
                           /* Extract part usage id */
                           params[0] = "p_usageid";
                           status = get_parameter_values(
                                                       &(head->part_id),
                                                       params,
                                                       1,
                                                       &param_vals
                                                      );
                         if (!status)
                            {
                             _pdm_debug("get_parameter_values failed", 0);

                             return(status);
                            }

                           /* Get the path to external dyn. attrs. */
                           di$give_pathname(
                                            osnum = head->part_id.osnum,
                                            pathname = path
                                           );

                           strcat(path, ":PDU:macro_parts:");
                           strcat(path, param_vals[0]);

                           _pdm_debug("external attr. full path = <%s>", path);

                           /* Extract external attr. value */
                           status = PDUevaluate_exp(
                                                    path,
                                                    attr_names[i],
                                                    &param_vals[0]
                                                   );
                           _pdm_status("PDUevaluate_exp", status);

                           if (status != PDM_S_SUCCESS)
                              {
                               _pdm_debug("<%s> must be a new attribute",
                                          attr_names[i]);
                               param_vals[0] = NULL;
                               PDUfill_in_string(&param_vals[0], "");
                              }
                          }

                       strcpy(attr_value, param_vals[0]);

                       /* Write dyn attr value to row */
                       PDUadd_buffer_string(
                                            row,
                                            &index,
                                            attr_value
                                           );

                      } /* end for loop */

                  /* Write row to data buffer */
                  status = MEMwrite(data_buffer, row);

                  if (status != MEM_S_SUCCESS)
                     {
                      _pdm_debug("failed writing to data_buffer buffer",0);
                      return(PDM_E_WRITE_ROW);
                     }

                  /* Print return_buffer contents */
                  if (PDMdebug_on)
                     MEMprint_buffer(
                                     "buffer of dyn attr names and values",
                                     data_buffer,
                                     PDU_DEBUG_FILE 
                                    );

                  /* Create new PDUpart_dyn_node node */
                  temp = (struct PDUpart_dyn_node *)
                         malloc(sizeof(struct PDUpart_dyn_node));

                  /* Initialize temp fields */
                  temp->catalog = NULL;
                  temp->data_buffer = NULL;
                  temp->next = NULL;

                  /* Load node */
                  PDUfill_in_string(&(temp->catalog), catalog);
                  MEMsplit_copy_buffer(
                                       data_buffer,
                                       &(temp->data_buffer),
                                       0
                                      );

                  /* Add node to the end of parts_dyn_attrs_list */
                  if (*parts_dyn_attrs_list)
                     {
                      /* Get to the end of list */
                      tail = *parts_dyn_attrs_list;
                      while (tail->next)
                            {
                             tail = tail->next;
                            }

                      /* Add part to link list */
                      tail->next = temp;
                     }

                  else
                     {
                      /* This is the first node in the list */
                      *parts_dyn_attrs_list = temp;
                     }

                  /* Close data_buffer buffer */
                  MEMclose(&data_buffer);
                  data_buffer = NULL;
                 }

            /* Process next node */
            head = head->next; 

           } /* end while loop */

     /* Free up variables */
     if (row)
        free(row);
    }

 else
     {
      /* Process regular parts */
      head = part_ids;

      while (head)
            {
             /* Extract catalog from part */
             co$part_get_attr (
                               msg = &msg,
                               mod_env = mod_env,
                               part = &(head->part_id),
                               attr = "CATALOG",
                               value = catalog,
                               type = &type
                              );

             /* Check to see if part dyn attrs have already been processed */
             top = *parts_dyn_attrs_list;
             catalog_found = FALSE;

             while (top)
                   {
                    if (strcmp(top->catalog, catalog) == 0)
                       {
                        catalog_found = TRUE;
                        break;
                       }

                    /* Process next node */
                    top = top->next;
                   } /* end while loop */ 

             if (catalog_found)
                {
                 _pdm_debug("catalog <%s> found", catalog);

                 /* Load dyn attrs to data buffer */
                 MEMbuild_array(top->data_buffer);
                 attr_names = (IGRchar **) (top->data_buffer)->column_ptr;
                 data_types = (IGRchar **) (top->data_buffer)->format_ptr;
                 row = (IGRchar *) malloc 
                               ((top->data_buffer)->row_size * sizeof(IGRchar));
                 memset(row, NULL, (top->data_buffer)->row_size);
                 index = 0;

                 /* Extract part child no */
                 co$part_get_attr (
                                   msg = &msg,
                                   mod_env = mod_env,
                                   part = &(head->part_id),
                                   attr = "child_no",
                                   value = child_no,
                                   type = &type
                                  );

                 /* Unquote child no */
                 PDUunquote(child_no);

                 /* Write child no to row */
                 PDUadd_buffer_string(
                                      row,
                                      &index,
                                      child_no
                                     );

                 /* Write a null value for pdcno column */
                 PDUadd_buffer_string(
                                      row,
                                      &index,
                                      ""
                                     );

                 /* Write dyn attrs values to row */
                 for (i = 2; i < (top->data_buffer)->columns; ++i)
                     {
                      /* Extract dyn attr value */
                      co$part_get_attr (
                                        msg = &msg,
                                        mod_env = mod_env,
                                        part = &(head->part_id),
                                        attr = attr_names[i],
                                        value = attr_value,
                                        type = &type
                                       );

                      if (msg != MSSUCC)
                         {
                          _pdm_debug("<%s> must be a new attribute",
                                           attr_names[i]);
                          strcpy(attr_value, "");
                         }

                      /* Check to see if dyn attr value needs to be unquoted */
                      _pdm_debug("attr_value = <%s>", attr_value);
                      if (strrchr(attr_value, '"'))
                         {
                          PDUunquote(attr_value);
                         }

                      /* Write dyn attr value to row */
                      PDUadd_buffer_string(
                                           row,
                                           &index,
                                           attr_value
                                          );

                     } /* end for loop */

                 /* Write row into data buffer */
                 status = MEMwrite(top->data_buffer, row);

                 if (status != MEM_S_SUCCESS)
                    {
                     _pdm_debug("MEMwrite failed", 0);
                     return(PDM_E_WRITE_ROW);
                    }
                }

             else
                 {
                  _pdm_debug("catalog <%s> not found", catalog);

                  /* Extract part number */
                  co$part_get_attr (
                                    msg = &msg,
                                    mod_env = mod_env,
                                    part = &(head->part_id),
                                    attr = "NUMBER",
                                    value = number,
                                    type = &type
                                   );

                  /* Extract part revision */
                  co$part_get_attr (
                                    msg = &msg,
                                    mod_env = mod_env,
                                    part = &(head->part_id),
                                    attr = "REVISION",
                                    value = revision,
                                    type = &type
                                   );

                  /* Check to see if part has any dynamic attrs */
                  status = PDMget_dyn_attr_names(
                                                 catalog,
                                                 number,
                                                 revision,
                                                 &data_buffer
                                                );

                  if (status != PDM_S_SUCCESS)
                     {
                      if (status == PDM_E_UNKNOWN_TABLE)
                         {
                          _pdm_debug("dynamic attrs do not exist for part <%s>",
                                 number);
                          return(PDM_S_SUCCESS);
                         }

                      _pdm_debug("PDMget_dyn_attr_names failed", 0);
                      return(status);
                     }

                  if (data_buffer == NULL)
                     {
                      _pdm_debug("dynamic attrs do not exist for part <%s>",
                                 number);
                      status = PDM_S_SUCCESS;
                     }

                  if ((status == PDM_S_SUCCESS) && (data_buffer))
                  {
                  /* Load dyn attrs to data buffer */
                  MEMbuild_array(data_buffer);
                  attr_names = (IGRchar **) data_buffer->column_ptr;
                  data_types = (IGRchar **) data_buffer->format_ptr;
                  row = (IGRchar *) malloc
                                   (data_buffer->row_size * sizeof(IGRchar));
                  memset(row, NULL, data_buffer->row_size);
                  index = 0;

                  /* Extract part child no */
                  co$part_get_attr (
                                    msg = &msg,
                                    mod_env = mod_env,
                                    part = &(head->part_id),
                                    attr = "child_no",
                                    value = child_no,
                                    type = &type
                                   );

                  /* Unquote child no */
                  PDUunquote(child_no);

                  /* Write child no to row */
                  PDUadd_buffer_string(
                                       row,
                                       &index,
                                       child_no
                                      );

                  /* Write a null value for pdcno column */
                  PDUadd_buffer_string(
                                       row,
                                       &index,
                                       ""
                                      );

                  /* Write dyn attrs values to row */
                  for (i = 2; i < data_buffer->columns; ++i)
                      {
                       /* Extract dyn attr value */
                       co$part_get_attr (
                                         msg = &msg,
                                         mod_env = mod_env,
                                         part = &(head->part_id),
                                         attr = attr_names[i],
                                         value = attr_value,
                                         type = &type
                                        );

                       if (msg != MSSUCC)
                          {
                           _pdm_debug("<%s> must be a new attribute",
                                       attr_names[i]);
                           strcpy(attr_value, "");
                          }

                       /* Check to see if dyn attr value needs to be unquoted */
                       if (strrchr(attr_value, '"'))
                          {
                           PDUunquote(attr_value);
                          }

                       /* Write dyn attr value to row */
                       PDUadd_buffer_string(
                                            row,
                                            &index,
                                            attr_value
                                           );
                      } /* end for loop */

                  /* Write row to buffer */
                  status = MEMwrite(data_buffer, row);

                  if (status != MEM_S_SUCCESS)
                     {
                      _pdm_debug("failed writing to data_buffer buffer",0);
                      return(PDM_E_WRITE_ROW);
                     }

                  /* Print return_buffer contents */
                  if (PDMdebug_on)
                     MEMprint_buffer(
                                     "buffer of dyn attr names and values",
                                     data_buffer,
                                     PDU_DEBUG_FILE 
                                    );

                  /* Create new PDUpart_dyn_node node */
                  temp = (struct PDUpart_dyn_node *)
                         malloc(sizeof(struct PDUpart_dyn_node));

                  /* Initialize temp fields */
                  temp->catalog = NULL;
                  temp->data_buffer = NULL;
                  temp->next = NULL;

                  /* Load node */
                  PDUfill_in_string(&(temp->catalog), catalog);
                  MEMsplit_copy_buffer(
                                       data_buffer,
                                       &(temp->data_buffer),
                                       0
                                      );

                  /* Add path node to the end of parts_dyn_attrs_list */
                  if (*parts_dyn_attrs_list)
                     {
                      /* Get to the end of list */
                      tail = *parts_dyn_attrs_list;
                      while (tail->next)
                            {
                             tail = tail->next;
                            }

                      /* Add part to link list */
                      tail->next = temp;
                     }

                  else
                     {
                      /* This is the first node in the list */
                      *parts_dyn_attrs_list = temp;
                     }

                  /* Close data_buffer buffer */
                  MEMclose(&data_buffer);
                  data_buffer = NULL;
                 }
                 }

             /* Process next node */
             head = head->next;

            } /* end while loop */

      /* Free up variables */
      if (row)
         free(row);
     }

 return(PDM_S_SUCCESS);
}


IGRint PDUcleanup_local_filemgr()
{
 IGRint               status = PDM_S_SUCCESS;
 MEMptr               local_files = NULL;
 MEMptr               detach_buffer = NULL;
 MEMptr               status_buffer = NULL;
 struct PDUattach_mac_node *head1 = NULL;
 struct               GRmd_env  my_env;
 extern MEMptr        PDU_detach_macro_lib;
 extern struct PDUattach_mac_node *PDU_attach_macro_lib;
 extern struct PDUstorage         *storage;
 extern OMuword   OM_Gw_TransOSnum_0 ;
 extern OMuword   OM_Gw_current_OS ;


 _pdm_debug("In PDUcleanup_local_filemgr", 0);

 if (OM_Gw_current_OS == OM_Gw_TransOSnum_0)
   return(PDM_S_SUCCESS);
 /* Load detach buffer */
 status = PDUload_detach_buffer(
                                NULL,
                                -1,
                                0,
                                &detach_buffer
                               );
 _pdm_status("PDUload_detach_buffer", status);

 if (status == PDM_S_SUCCESS)
    {
     /* Clean up local files, if necessary */
     if (detach_buffer)
        {
         if (detach_buffer->rows > 0)
            {
             /* Need to check if logged in */
             status  = PDUautomatic_login();
             _pdm_status("PDUautomatic_login", status);

             if (status == PDM_S_SUCCESS)
                {
                 status = PDMdetach_part(detach_buffer);
                 _pdm_status("PDMdetach_part", status);

                 if (status != PDM_S_SUCCESS)
                    {
                     _pdm_debug("SEVERE error: PDMdetach_part failed", 0);
                    }
                 }

             else
                 {
                  _pdm_debug("PDUautomatic_login failed", 0);
                 }
           
            }

         /* Free up buffer */
         MEMclose(&detach_buffer);
         detach_buffer = NULL;
        }
    }

 else
     {
      _pdm_debug("PDUload_detach_buffer failed", 0);
     }

  PDMreset_transfer_status(refresh->rev_catalog, refresh->rev_partid, 
                           refresh->rev_revision);
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
                /* Delete local macro libraries */
                status = PDUremove_local_files_after_delete(local_files);
                _pdm_debug("PDUremove_local_files_after_delete", status);
               }  
                   
            /* Process next node */
            head1 = head1->next;

           } /* end while loop */

     /* Free variables */
     if (local_files)
        {
        MEMclose(&local_files);
        local_files = NULL;
        }
    }

 if ( (strcmp(refresh->rev_catalog, "") != 0) &&
      (strcmp(refresh->rev_partid, "") != 0) &&
      (strcmp(refresh->rev_revision, "") != 0) )
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

     /* Restore update os flag setting. */
     PDMset_update_os_flag("U");
    }

 else
     {
      /* Load exec structure */
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
     
      /* Restore update os flag setting. */
      PDMset_update_os_flag("U");
     }

 return(PDM_S_SUCCESS);
}

/*
 * Function to prepare a list of unique catalogs of parametric parts in an 
 * object space.
 */
 IGRint PDUprepare_param_cats_list(
                                   mod_env,         /* INPUT */
                                   param_cat_list   /* OUTPUT */
                                  )
  struct  GRmd_env      *mod_env;
  struct  PDUcat_node   **param_cat_list;
  {
   IGRint               status = PDM_S_SUCCESS;
   IGRint               i;
   IGRint               cat_col;
   IGRint               part_count = 0;
   IGRchar              assy_path[DI_PATH_MAX];
   IGRchar              *catalog = NULL;
   IGRchar              *parttype = NULL;
   IGRchar              **data_row = NULL;
   IGRchar              **parts = NULL;
   IGRshort             found;
   struct  PDUcat_node  *head = NULL;
   struct  PDUcat_node  *temp = NULL;
   struct  PDUcat_node  *tail = NULL;
   IGRint               count = 0;
   struct PDUpart_node *parametric_ids = NULL;
   struct PDUpart_node *head1 = NULL;

   _pdm_debug("In the PDUprepare_param_cats_list function", 0);

   /* Initialize param_cat_list */
   *param_cat_list = NULL;

   /* Free up PDU_param_buffer buffer */
   if (PDU_param_buffer)
      {
       MEMclose(&PDU_param_buffer);
       PDU_param_buffer = NULL;
      }

   /* Free up PDUchild_dyn_buffer buffer */
   if (PDUchild_dyn_buffer)
      {
       MEMclose(&PDUchild_dyn_buffer);
       PDUchild_dyn_buffer = NULL;
      }

   /* Free up PDU_child_buffer buffer */
   if (PDU_child_buffer)
      {
       MEMclose(&PDU_child_buffer);
       PDU_child_buffer = NULL;
      }

   /* Check to see if parametric parts exist */
   status = PDUget_all_parametric_ids(
                                      (*mod_env).md_id.osnum,
                                      &parametric_ids,
                                      &count
                                     );
   _pdm_status("PDUget_all_parametric_ids", status);

   if (count > 0)
      {
       /* Free parametric_ids */
       if (parametric_ids)
          {
           head1 = parametric_ids;

           while (parametric_ids)
                 {
                  parametric_ids = parametric_ids->next;
                  free(head1);
                  head1 = parametric_ids;
                 }
          }
      }

   else
       {
        _pdm_debug("no parametric parts were found", 0);
        di$give_pathname(osnum = mod_env->md_id.osnum, pathname = assy_path);
        strcat(assy_path, ":ASSEMBLY");
        status = di$find(start_dir = assy_path, regexp = "P*", lines = &parts,
                         ptr = &part_count, max_level = -1);
        if ((status == DIR_S_SUCCESS) && (part_count > 0))
          {
          for (i = 0; i < part_count; i++)
            {
            PDUstrip_dir_entry(parts[i]);
            status = PDUevaluate_exp(parts[i], "part_type", &parttype);
            _pdm_status("PDUevaluate_exp part_type", status);
            if (status != PDM_S_SUCCESS)
              return(PDM_S_SUCCESS);
            _pdm_debug("parttype = <%s>", parttype);
            if ((strcmp(parttype, "P") == 0) || (strcmp(parttype, "p") == 0))
              {
              status = PDUevaluate_exp(parts[i], "catalog_name", &catalog);
              _pdm_status("PDUevaluate_exp catalog_name", status);
              if (status != PDM_S_SUCCESS)
                return(PDM_S_SUCCESS);
              head = *param_cat_list;
              found = FALSE;
              while (head)
                {
                if (strcmp(head->catalog, catalog) == 0)
                  {
                  /* increment ref count */
                  ++(head->count);
                  found = TRUE;
                  break;
                  }
                head = head->next;
                }
              if (!found)
                {
                temp = (struct PDUcat_node *)malloc(sizeof(struct PDUcat_node));
                temp->catalog = NULL;
                temp->count = 1;
                temp->next = NULL;
                PDUfill_in_string(&(temp->catalog), catalog);
                if (*param_cat_list)
                  {
                  tail = *param_cat_list;
                  while (tail->next)
                    {
                    tail = tail->next;
                    }
                 tail->next = temp;
                 }
               else
                 {
                 *param_cat_list = temp;
                 }
               }
             }
           }
         }
        if (catalog)
          free(catalog);
        if (parttype)
          free(parttype);
        if (parts)
          di$free(lines = parts, count = part_count);
        return(PDM_S_SUCCESS);
       }

   /* Initialize PDU_dyn_index */
   PDU_dyn_index = 1;

   /* Load parametric checkin info */
   status = PALchekin(mod_env);
   _pdm_status("PALcheckin", status);

   if (!status)
      {
       _pdm_debug("PALchekin failed", 0);
       return(status);
      }

   /* Construct param_cat_list link list */
   if (PDU_child_buffer)
      {
       if (PDU_child_buffer->rows > 0)
          {
           status = MEMbuild_array(PDU_child_buffer);
           _pdm_status("MEMbuild_array", status);

           if (status != MEM_S_SUCCESS)
              {
               status = PDM_E_BUILD_BUFFER_ARRAY;
               PDUmessage(status, 's');
               return(status);
              }

           PDUsetup_buffer(PDU_child_buffer, ROW, &data_row);
           PDUget_buffer_col(PDU_child_buffer, "n_catalogname", &cat_col);

           for (i = 0; i < PDU_child_buffer->rows; ++i)
               {
                head = *param_cat_list;
                found = FALSE;

                while (head)
                      {
                       if (strcmp(
                                  head->catalog,
                               data_row[(PDU_child_buffer->columns*i) + cat_col]
                                 ) == 0)
                          {
                           /* Increment reference count */
                           ++(head->count);

                           found = TRUE;
                           break;
                          }

                       head = head->next;
                      } 

                if (!found)
                   {
                    /* Create a node with catalog name */
                    temp = (struct PDUcat_node *)
                           malloc(sizeof(struct PDUcat_node));

                    /* Initialize temp fields */
                    temp->catalog = NULL;
                    temp->count = 1;
                    temp->next = NULL;
                    PDUfill_in_string(&(temp->catalog),
                             data_row[(PDU_child_buffer->columns*i) + cat_col]);

                    if (*param_cat_list)
                       {
                        /* Get to the end of list */
                        tail = *param_cat_list;
                        while (tail->next)
                              {
                               tail = tail->next;
                              }

                        /* Add catalog name to link list */
                        tail->next = temp;
                       }

                    else
                       {
                        /* This is the first node in the list */
                        *param_cat_list = temp;
                       }
                   }

            } /* end for i loop */
         }

       /* Free up PDU_child_buffer */
       MEMclose(&PDU_child_buffer);
       PDU_child_buffer = NULL;
      }

   if (PDU_param_buffer)
      {
       if (PDU_param_buffer->rows > 0)
          {
           status = MEMbuild_array(PDU_param_buffer);
           _pdm_status("MEMbuild_array", status);

           if (status != MEM_S_SUCCESS)
              {
               status = PDM_E_BUILD_BUFFER_ARRAY;
               PDUmessage(status, 's');
               return(status);
              }

           PDUsetup_buffer(PDU_param_buffer, ROW, &data_row);
           PDUget_buffer_col(PDU_param_buffer, "n_catalogname", &cat_col);

           for (i = 0; i < PDU_param_buffer->rows; ++i)
               {
                head = *param_cat_list;
                found = FALSE;

                while (head)
                      {
                       if (strcmp(
                                  head->catalog,
                               data_row[(PDU_param_buffer->columns*i) + cat_col]
                                 ) == 0)
                          {
                           /* Increment reference count */
                           ++(head->count);

                           found = TRUE;
                           break;
                          }

                       head = head->next;
                      } 

                if (!found)
                   {
                    /* Create a node with catalog name */
                    temp = (struct PDUcat_node *)
                           malloc(sizeof(struct PDUcat_node));

                    /* Initialize temp fields */
                    temp->catalog = NULL;
                    temp->count = 1;
                    temp->next = NULL;
                    PDUfill_in_string(&(temp->catalog),
                             data_row[(PDU_param_buffer->columns*i) + cat_col]);

                    if (*param_cat_list)
                       {
                        /* Get to the end of list */
                        tail = *param_cat_list;
                        while (tail->next)
                              {
                               tail = tail->next;
                              }

                        /* Add catalog name to link list */
                        tail->next = temp;
                       }

                    else
                       {
                        /* This is the first node in the list */
                        *param_cat_list = temp;
                       }
                   }

               } /* end for i loop */
         }

       /* Free up PDU_param_buffer */
       if (PDU_param_buffer)
          {
           MEMclose(&PDU_param_buffer);
           PDU_param_buffer = NULL;
          }

      /* Free up PDUchild_dyn_buffer buffer */
      if (PDUchild_dyn_buffer)
         {
          MEMclose(&PDUchild_dyn_buffer);
          PDUchild_dyn_buffer = NULL;
         }
      }

   di$give_pathname(osnum = mod_env->md_id.osnum, pathname = assy_path);
   strcat(assy_path, ":ASSEMBLY");
   status = di$find(start_dir = assy_path, regexp = "P*", lines = &parts,
                      ptr = &part_count, max_level = -1);
   if ((status == DIR_S_SUCCESS) && (part_count > 0))
     {
     for (i = 0; i < part_count; i++)
       {
       PDUstrip_dir_entry(parts[i]);
       status = PDUevaluate_exp(parts[i], "part_type", &parttype);
       _pdm_status("PDUevaluate_exp part_type", status);
      if (status != PDM_S_SUCCESS)
        return(PDM_S_SUCCESS);
       _pdm_debug("parttype = <%s>", parttype);
      if ((strcmp(parttype, "P") == 0) || (strcmp(parttype, "p") == 0))
        {
         status = PDUevaluate_exp(parts[i], "catalog_name", &catalog);
         _pdm_status("PDUevaluate_exp catalog_name", status);
         if (status != PDM_S_SUCCESS)
           return(PDM_S_SUCCESS);
         head = *param_cat_list;
         found = FALSE;
         while (head)
           {
           if (strcmp(head->catalog, catalog) == 0)
             {
             /* increment ref count */
             ++(head->count);
             found = TRUE;
             break;
             }
           head = head->next;
           }
         if (!found)
           {
           temp = (struct PDUcat_node *)malloc(sizeof(struct PDUcat_node));
           temp->catalog = NULL;
           temp->count = 1;
           temp->next = NULL;
           PDUfill_in_string(&(temp->catalog), catalog);
           if (*param_cat_list)
             {
             tail = *param_cat_list;
             while (tail->next)
               {
                tail = tail->next;
                }
             tail->next = temp;
             }
           else
             {
             *param_cat_list = temp;
              }
            }
          }
        }
      }
     if (catalog)
        free(catalog);
     if (parttype)
       free(parttype);
     if (parts)
       di$free(lines = parts, count = part_count);
   return(PDM_S_SUCCESS); 
  }

/*
 * This function clears checkin info. buffers.
 */
 
void PDUclear_checkin_buffers()
     {
      struct PDUcat_node                 *head = NULL;

      extern MEMptr                      PDU_child_buffer;
      extern MEMptr                      PDU_attach_bufr;
      extern MEMptr                      PDU_view_buffer;
      extern MEMptr                      PDU_param_buffer;
      extern MEMptr                      PDUchild_dyn_buffer;
      extern MEMptr                      PDU_dyn_attr_bufr;
      extern MEMptr                      PDU_dyn_data_bufr;
      extern struct PDUcat_node          *PDU_param_cat_list;
      extern int                         PDU_dyn_index;


      _pdm_debug("In the PDUclear_checkin_buffers function", 0);


      /* Initialize global variables */
      if (PDU_child_buffer)
         {
          MEMclose(&PDU_child_buffer);
          PDU_child_buffer = NULL;
         }

      if (PDU_attach_bufr)
         {
          MEMclose(&PDU_attach_bufr);
          PDU_attach_bufr = NULL;
         }

      if (PDU_view_buffer)
         {
          MEMclose(&PDU_view_buffer);
          PDU_view_buffer = NULL;
         }

      if (PDU_param_buffer)
         {
          MEMclose(&PDU_param_buffer);
          PDU_param_buffer = NULL;
         }

      if (PDUchild_dyn_buffer)
         {
          MEMclose(&PDUchild_dyn_buffer);
          PDUchild_dyn_buffer = NULL;
         }

      if (PDU_dyn_attr_bufr)
         {
          MEMclose(&PDU_dyn_attr_bufr);
          PDU_dyn_attr_bufr = NULL;
         }

      if (PDU_dyn_data_bufr)
         {
          MEMclose(&PDU_dyn_data_bufr);
          PDU_dyn_data_bufr = NULL;
         }
      
      if (PDU_param_cat_list)
         {
          head = PDU_param_cat_list;

          while (PDU_param_cat_list)
                {
                 PDU_param_cat_list = PDU_param_cat_list->next;
                 free(head);
                 head = PDU_param_cat_list;
                } /* end while loop */

          PDU_param_cat_list = NULL;
         }

      /* Reset PDU_dyn_index */
      PDU_dyn_index = 1;
     }


/*
 * This function loades the OS part checkin info.
 */

IGRint PDUload_active_checkin_info()
 {
  IGRint                   status = PDM_S_SUCCESS;
  IGRint                   count = 0;
  IGRint                   bufsiz;
  struct GRmd_env          mod_env;
  struct PDUpart_node      *parametric_ids = NULL;
  struct PDUpart_node      *head = NULL;

  extern struct PDUcat_node        *PDU_param_cat_list;
  extern MEMptr                    PDUchild_dyn_buffer;
  extern MEMptr                    PDU_child_buffer;
  extern MEMptr                    PDU_attach_bufr;
  extern MEMptr                    PDU_view_buffer;
  extern MEMptr                    PDU_param_buffer;
  extern MEMptr                    PDUchild_dyn_buffer;
  extern int                       PDU_dyn_index;
  extern MEMptr                    PDU_dyn_attr_bufr;
  extern MEMptr                    PDU_dyn_data_bufr;

  _pdm_debug("In the PDUload_active_checkin_info function", 0);

  /* Clear checkin info. buffers */
  PDUclear_checkin_buffers();

  /* Get current module info. */
  bufsiz = sizeof(struct GRmd_env);
  gr$get_module_env(sizbuf = &bufsiz, buffer = &mod_env);

  /* Check to see if parametric parts exist */
  status = PDUget_all_parametric_ids(
                                     mod_env.md_id.osnum,
                                     &parametric_ids,
                                     &count
                                    );
  _pdm_status("PDUget_all_parametric_ids", status);

  if (count > 0)
     {
      /* Free parametric_ids */
      if (parametric_ids)
         {
          head = parametric_ids;

          while (parametric_ids)
                {
                 parametric_ids = parametric_ids->next;
                 free(head);
                 head = parametric_ids;
                }
         }

      /* Load PDU_param_cat_list list */
      status = PDUprepare_param_cats_list(
                                          &mod_env,
                                          &PDU_param_cat_list
                                         );
      _pdm_status("PDUprepare_param_cats_list", status);

      if (status != PDM_S_SUCCESS)
         {
          _pdm_debug("PDUprepare_param_cats_list failed", 0);
          return(0);
         }

      /* Initialize parametric assembly buffer */
      PDU_param_buffer = NULL;
      PDUchild_dyn_buffer = NULL;

      /* Initialize PDU_dyn_index */
      PDU_dyn_index = 1;

      /* Load parametric checkin info */
      status = PALchekin(&mod_env);
      _pdm_status("PALcheckin", status);

      if (!status)
         {
          _pdm_debug("PALcheckin failed", 0);
          return(0);
         }
     }  
    else
      {
      /* Load PDU_param_cat_list list */
      status = PDUprepare_param_cats_list(
                                          &mod_env,
                                          &PDU_param_cat_list
                                         );
      _pdm_status("PDUprepare_param_cats_list", status);

      if (status != PDM_S_SUCCESS)
         {
          _pdm_debug("PDUprepare_param_cats_list failed", 0);
          return(0);
         }
      }

  /* Load part child buffer */
  status = PDUload_child_buffer(
                                &PDU_child_buffer,
                                mod_env
                               );
  if (status != PDM_S_SUCCESS)
     {
      _pdm_debug("PDUload_child_buffer failed", 0);
      return(0);
     }

  /* Extract part attachment info */
  status = PDUload_attach_buffer(
                                 &PDU_attach_bufr,
                                 mod_env
                                );

  if (status != PDM_S_SUCCESS)
     {
      _pdm_debug("PDUload_attach_buffer failed", 0);
      return(0);
     }

 /* Extarct dynamic attributes */
 status = PDUload_dynamic_attrs(
                                &mod_env,
                                &PDU_dyn_attr_bufr,
                                &PDU_dyn_data_bufr
                               );
 _pdm_status("PDUload_dynamic_attrs", status);

 if (status != PDM_S_SUCCESS)
    {
     _pdm_debug("PDU_dynamic_attrs failed", 0);
     return(0);
    }

 /* Extract view info */
 status = PDUload_view_info(
                            mod_env.md_id.objid,
                            mod_env.md_id.osnum,
                            &PDU_view_buffer
                           );
 _pdm_status("PDUload_view_info", status);

 if ( (status != PDM_S_SUCCESS) &&
      (status != PDM_I_ORIGIN_NOT_FOUND) )
    {
     _pdm_debug("PDUload_view_info failed", 0);
     return(0);
    }

  return(PDM_S_SUCCESS);
 }


/*
 * This function displays the list of part files.
 */
 
IGRint PDUselect_PDU_file(
                          catalog,
                          number,
                          revision,
                          active_filename
                         )
  IGRchar             *catalog;
  IGRchar             *number;
  IGRchar             *revision;
  IGRchar             *active_filename;

 {
  IGRint              status = PDM_S_SUCCESS;
  IGRchar             **data_row = NULL;
  IGRint              file_col = 0;
  IGRint              msg;
  IGRint              i;
  IGRint              index = -1;
  IGRchar             **om_data = NULL;
  char                *msg_str = NULL;
  MEMptr              om_files = NULL;
  IGRlong    NumberOfBytes, BytesReceived;
  struct      GRmd_env *mod_env = NULL;
  extern MEMptr       PDU_ret_bufr;


  _pdm_debug("In the PDUselect_PDU_file function", 0);

  /* Get list of files associated with part */
  status = PDMget_filenames(
                            catalog,
                            number,
                            revision,
                            &PDU_ret_bufr
                           );
  _pdm_status("PDMget_filenames", status);

  if (PDU_ret_bufr)
     {
      status = MEMbuild_array(PDU_ret_bufr);
      _pdm_status("MEMbuild_array", status);

      if (status != MEM_S_SUCCESS)
         {
          status = PDM_E_BUILD_BUFFER_ARRAY;
          PDUmessage(status, 's');
          return(0);
         }

      PDUsetup_buffer(PDU_ret_bufr, ROW, &data_row);
      PDUget_buffer_col(PDU_ret_bufr, "n_cofilename", &file_col);

      if (PDU_ret_bufr->rows == 1)
         {
          PDUfill_in_string(
                            &PDU_checkin_file,
                            data_row[file_col]
                           );
          return(PDM_S_SUCCESS);
         }

      else
          {
          for (i = 0; i < PDU_ret_bufr->rows; i ++)
           {
           _pdm_debug("verify files exist locally", 0);
           if ((data_row[(PDU_ret_bufr->columns * i) + file_col]) &&
               (strcmp(data_row[(PDU_ret_bufr->columns * i) + file_col], 
                active_filename) != 0))
             {
             status = PDUverify_file(data_row[(PDU_ret_bufr->columns * i) 
                                     + file_col]);
             _pdm_status("PDUverify_file", status);
             if (status != PDM_S_SUCCESS)
               return(status);
              }
            }
               
          mod_env = (struct GRmd_env *)malloc(sizeof(struct GRmd_env));
          NumberOfBytes = sizeof(struct GRmd_env);
          gr$get_module_env(
                              msg = &msg,
                              sizbuf = &NumberOfBytes,
                              buffer = mod_env,
                              nret = &BytesReceived);

           /* Display checkin file form */
           status = PDUfind_PDU_stamp_files(PDU_ret_bufr, active_filename,
                                            &om_files, mod_env, &index);
           _pdm_status("PDUfind_PDU_stamp_files", status);
           if (status != PDM_S_SUCCESS)
             return(status);
           if (om_files->rows == 1)
             {
             status = MEMbuild_array(om_files);
             _pdm_status("MEMbuild_array", status);
             if (status != MEM_S_SUCCESS)
               return(PDM_E_BUILD_BUFFER_ARRAY);
             om_data = (char **)om_files->data_ptr;
             status = PDUget_buffer_col(om_files, "n_cofilename", &file_col);
             _pdm_status("PDUget_buffer_col", status);
             if (status != PDM_S_SUCCESS)
               return(status);
             PDUfill_in_string(&PDU_checkin_file, om_data[file_col]);
             gr$get_module_env(
                              msg = &msg,
                              sizbuf = &NumberOfBytes,
                              buffer = mod_env,
                              nret = &BytesReceived);
             if (index != -1) 
               {
               status = ex$close_module(index = index, flag = 0,
                                        ftype = EX_invisible);
               _pdm_status("ex$close_module", status);
               }

             return(PDM_S_SUCCESS);
             }
             
           status = PDUdisplay_checkin_files();
           _pdm_status("PDUdisplay_checkin_files", status);

           msg_str = (char *)PDUtranslate_message(PDM_I_FILE_DEFASSEM_STRUCT);
           UI_status(msg_str);
           status = WaitForEvent();
           _pdm_status("WaitForEvent", status);

           if (!status)
              {
               _pdm_debug("checkin form was cancelled", 0);
               return(PDM_E_CMD_CANCELLED);
              }
           gr$get_module_env(
                            msg = &msg,
                            sizbuf = &NumberOfBytes,
                            buffer = mod_env,
                            nret = &BytesReceived);
           if (index != -1) 
             {
             status = ex$close_module(index = index, flag = 1,
                                      ftype = EX_invisible);
             _pdm_status("ex$close_module", status);
             }
          }
     }

  return(PDM_S_SUCCESS);
 }
 
IGRint PDUcheck_if_graphic(filename)

IGRchar *filename;
{
 IGRshort         major;
 IGRshort         minor;
 IGRchar          mach_type;
 IGRint           file_type;
 IGRlong          status;

  _pdm_debug("PDUcheck_if_graphic", 0);
  status = ex$is_om_file(
                                 filename = filename,
                                 p_major = &major,
                                 p_minor = &minor,
                                 p_mach_type = &mach_type,
                                 p_file_type = &file_type
                                );
   _pdm_status("ex$is_om_file", status);
   _pdm_debug("file_type = %d", file_type);

  if (status)
    status = PDM_S_SUCCESS;
  else
    status = PDM_E_FAILURE;

  return(status);
  }


IGRint PDUload_inactive_checkin_info(filename)
IGRchar *filename;
 {
  IGRint                   status = PDM_S_SUCCESS;
  IGRint                   count = 0;
  IGRint                   bufsiz;
  IGRint                   index = 0;
  IGRint                   msg;
  IGRint                   save_flag = 0;
  IGRchar                  mount_name[40];
  OMuword                  osnum;
  GRobjid                  objid;
  GRobjid                  osid = NULL_OBJID;
  struct GRmd_env          mod_env;
  struct PDUpart_node      *parametric_ids = NULL;
  struct PDUpart_node      *head = NULL;

  extern struct PDUcat_node        *PDU_param_cat_list;
  extern MEMptr                    PDUchild_dyn_buffer;
  extern MEMptr                    PDU_child_buffer;
  extern MEMptr                    PDU_attach_bufr;
  extern MEMptr                    PDU_view_buffer;
  extern MEMptr                    PDU_param_buffer;
  extern MEMptr                    PDUchild_dyn_buffer;
  extern int                       PDU_dyn_index;
  extern MEMptr                    PDU_dyn_attr_bufr;
  extern MEMptr                    PDU_dyn_data_bufr;

  _pdm_debug("In the PDUload_inactive_checkin_info function", 0);

  /* Clear checkin info. buffers */
  PDUclear_checkin_buffers();

  /* Get current module info. */
  bufsiz = sizeof(struct GRmd_env);
  gr$get_module_env(sizbuf = &bufsiz, buffer = &mod_env);

  /* Construct file mount name */
  strcpy(mount_name, ":");
  strcat(mount_name, filename);

  /* Get osnum of invis space */
  status = ex$retrieve_module (
                               filename = filename,
                               file_no = &index,
                               ftype = EX_invisible,
                               flag = EX_read_write,
                               fstat = EX_default,
                               type = EX_ACTINV,
                               mount_name = mount_name,
                               msg = &msg
                               );
  _pdm_status ("ex$retrieve_module", status);

  if (!status)
    {
       _pdm_debug("ex$retrieve_module failed on <%s>", filename);
        return(PDM_E_OPEN_FILE);
    }

  /* Open object space */
  status = ex$get_invis_info_by_index (
                                       index = index,
                                       mod_osnum = &osnum,
                                       mod_id = &objid,
                                       filed_id = &osid
                                       );
  _pdm_status ("ex$get_invis_info_by_index", status);

  if (!status)
    {
     _pdm_debug("ex$get_invis_info_by_index failed on <%s>", filename);
     return(PDM_E_OPEN_FILE);
    }

  mod_env.md_id.osnum = osnum;
  mod_env.md_id.objid = objid;

  /* Check to see if parametric parts exist */
  status = PDUget_all_parametric_ids(
                                     mod_env.md_id.osnum,
                                     &parametric_ids,
                                     &count
                                    );
  _pdm_status("PDUget_all_parametric_ids", status);

  if (count > 0)
     {
      /* Free parametric_ids */
      if (parametric_ids)
         {
          head = parametric_ids;

          while (parametric_ids)
                {
                 parametric_ids = parametric_ids->next;
                 free(head);
                 head = parametric_ids;
                }
         }

      /* Load PDU_param_cat_list list */
      status = PDUprepare_param_cats_list(
                                          &mod_env,
                                          &PDU_param_cat_list
                                         );
      _pdm_status("PDUprepare_param_cats_list", status);

      if (status != PDM_S_SUCCESS)
         {
          _pdm_debug("PDUprepare_param_cats_list failed", 0);
         /* Close and do not save object space */
         status = ex$close_module (
                                  index = index,
                                  flag = save_flag | EX_ACTINV,
                                  ftype = EX_invisible
                                  );
         _pdm_status ("ex$close_module", status);
          return(0);
         }

      /* Initialize parametric assembly buffer */
      PDU_param_buffer = NULL;
      PDUchild_dyn_buffer = NULL;

      /* Initialize PDU_dyn_index */
      PDU_dyn_index = 1;

      /* Load parametric checkin info */
      status = PALchekin(&mod_env);
      _pdm_status("PALcheckin", status);

      if (!status)
         {
          _pdm_debug("PALcheckin failed", 0);
         /* Close and do not save object space */
         status = ex$close_module (
                                  index = index,
                                  flag = save_flag | EX_ACTINV,
                                  ftype = EX_invisible
                                  );
         _pdm_status ("ex$close_module", status);
          return(0);
         }
     }  
    else
      {
      /* Load PDU_param_cat_list list */
      status = PDUprepare_param_cats_list(
                                          &mod_env,
                                          &PDU_param_cat_list
                                         );
      _pdm_status("PDUprepare_param_cats_list", status);

      if (status != PDM_S_SUCCESS)
         {
          _pdm_debug("PDUprepare_param_cats_list failed", 0);
         /* Close and do not save object space */
         status = ex$close_module (
                                  index = index,
                                  flag = save_flag | EX_ACTINV,
                                  ftype = EX_invisible
                                  );
         _pdm_status ("ex$close_module", status);
          return(0);
         }
       }


  /* Load part child buffer */
  status = PDUload_child_buffer(
                                &PDU_child_buffer,
                                mod_env
                               );
  if (status != PDM_S_SUCCESS)
     {
      _pdm_debug("PDUload_child_buffer failed", 0);
      /* Close and do not save object space */
      status = ex$close_module (
                               index = index,
                               flag = save_flag | EX_ACTINV,
                               ftype = EX_invisible
                               );
      _pdm_status ("ex$close_module", status);
      return(0);
     }

  /* Extract part attachment info */
  status = PDUload_attach_buffer(
                                 &PDU_attach_bufr,
                                 mod_env
                                );

  if (status != PDM_S_SUCCESS)
     {
      _pdm_debug("PDUload_attach_buffer failed", 0);
      /* Close and do not save object space */
      status = ex$close_module (
                               index = index,
                               flag = save_flag | EX_ACTINV,
                               ftype = EX_invisible
                               );
      _pdm_status ("ex$close_module", status);
      return(0);
     }

 /* Extarct dynamic attributes */
 status = PDUload_dynamic_attrs(
                                &mod_env,
                                &PDU_dyn_attr_bufr,
                                &PDU_dyn_data_bufr
                               );
 _pdm_status("PDUload_dynamic_attrs", status);

 if (status != PDM_S_SUCCESS)
    {
     _pdm_debug("PDU_dynamic_attrs failed", 0);
     /* Close and do not save object space */
     status = ex$close_module (
                               index = index,
                               flag = save_flag | EX_ACTINV,
                               ftype = EX_invisible
                               );
     _pdm_status ("ex$close_module", status);
     return(0);
    }

 /* Extract view info */
 status = PDUload_view_info(
                            mod_env.md_id.objid,
                            mod_env.md_id.osnum,
                            &PDU_view_buffer
                           );
 _pdm_status("PDUload_view_info", status);

 if ( (status != PDM_S_SUCCESS) &&
      (status != PDM_I_ORIGIN_NOT_FOUND) )
    {
     _pdm_debug("PDUload_view_info failed", 0);
     /* Close and do not save object space */
     status = ex$close_module (
                               index = index,
                               flag = save_flag | EX_ACTINV,
                               ftype = EX_invisible
                               );
     _pdm_status ("ex$close_module", status);
     return(0);
    }

 if (!(PDUis_PDU_design_file(&mod_env)))
   {
   status = PDUstamp_PDU_design_file(mod_env);
   _pdm_status("PDUstamp_PDU_design_file", status);
   }

 save_flag = 1;
 /* Close and save object space */
 status = ex$close_module (
                           index = index,
                           flag = save_flag | EX_ACTINV,
                           ftype = EX_invisible
                           );
 _pdm_status ("ex$close_module", status);

  return(PDM_S_SUCCESS);
 }

IGRshort PDUis_checkin_file_attached(mod_env, checkin_file)

struct GRmd_env *mod_env;
IGRchar *checkin_file;

  {
  IGRint status;
  IGRshort file_found;
  struct PDUref_node *head = NULL;
  extern struct PDUref_node *PDU_ref_filenames;

  _pdm_debug("PDUis_checkin_file_attached", 0);
  
  if (PDU_ref_filenames)
    {
    head = PDU_ref_filenames;
    while (PDU_ref_filenames)
      {
      PDU_ref_filenames = PDU_ref_filenames->next;
      free(head);
      head = PDU_ref_filenames;
      }
    }

  status = PDUget_all_ref_file_names(mod_env);
  _pdm_status("PDUget_all_ref_file_names", status);

  if (PDU_ref_filenames == NULL)
    return(0);
  
  file_found = FALSE;
  head = PDU_ref_filenames;
  while (head)
    {
    if (strcmp(head->filename, checkin_file) == 0)
      {
      _pdm_debug("checkin file is attached as ref file", 0);
      file_found = TRUE;
      break;
      }
    head = head->next;
    }

  return(file_found);
  }
     

end implementation COpdu;
