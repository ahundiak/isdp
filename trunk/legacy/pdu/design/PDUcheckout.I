class implementation COpdu;
/*
   This file contains object space related functions involved in the checking
   out of a part.

   Author: Jamal Shakra
   Date: 26-9-93
*/

/* Include file section */
#include        <stdio.h>
#include        <unistd.h>
#include        "DIdef.h"
#include        "DItypedef.h"
#include        "DIprims.h"
#include        "DIglob.h"
#include        "expriv.h"
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
#include        "OMindex.h"
#include        "MEMstruct.h"
#include        "MEMerrordef.h"
#include        "comnmacros.h"
#include        "ctype.h"
#include        "PDUuser.h"
#include        "PDUfile_def.h"
#include        "PDUgrpart.h"
#include        "PDUnode.h"
#include        "PDUprompt.h"
#include        "PDUassy.h"
#include        "PDMmessage.h"
#include        "PDUforms.h"
#include        "sys/stat.h"


/* Global external variables */
extern  int      PDMdebug_on;
extern  Form     PDU_form_id;
extern struct PDUforms forms;

/* Global variables */

/* Imported messages */

/*
 * This function checks out a part. It also updates the part object space with
 * the new assembly structure information. This function supports the editing of
 * the assembly display structure.
 */
IGRint  PDUcheckout_part(
                         file_bufr,
                         assy_struct_bufr,
                         display_assembly
                        )
 MEMptr    file_bufr;          /* INPUT */
 MEMptr    assy_struct_bufr;   /* INPUT */
 IGRshort  display_assembly;   /* INPUT */


 {
  IGRlong                   status = PDM_S_SUCCESS;
  IGRint                    msg;
  struct                    GRmd_env  mod_env;
  IGRchar                   **data_row = NULL;
  IGRint                    file_col;
  IGRint                    index = 0;
  IGRchar                   mount_name[40];
  IGRshort                  major;
  IGRshort                  minor;
  IGRshort                  file_already_open = FALSE;
  GRobjid                   objid;
  IGRchar                   mach_type;
  GRobjid                   osid = NULL_OBJID;
  OMuword                   osnum;
  IGRint                    row;
  IGRint                    count = 0;
  IGRchar                   stamp_path[DI_PATH_MAX];
  IGRchar                   old_origins_dir[DI_PATH_MAX];
  IGRchar                   old_parts_dir[DI_PATH_MAX];
  IGRchar                   view_table[20];
  IGRchar                   *file = NULL;
  IGRchar                   *catalog_no = NULL;
  IGRchar                   *item_no = NULL;
  IGRint                    file_type;
  IGRshort                  cvt_file;
  IGRlong                   NumberOfBytes, BytesReceived;
  MEMptr                    display_buffer = NULL;
  MEMptr                    child_bufr = NULL;
  MEMptr                    citno = NULL;
  MEMptr                    new_set = NULL;
  MEMptr                    tmp_assy_bufr = NULL;
  MEMptr                    dyn_attr = NULL;
  MEMptr                    dyn_data = NULL;
  IGRint		    catno, itemno;
  IGRchar                   assembly_path[DI_PATH_MAX];
  IGRint                    part_count = 0;
  IGRchar                   **parts = NULL;
  IGRchar                   *local_flag = NULL;

  extern  IGRshort          PDU_activate_reffile_display;
  extern  IGRshort          PDU_edit_display;
  extern  struct            PDUrefresh *refresh;

  _pdm_debug("In the PDUcheckout_part function", 0);

  /*
    * TR# 139423521. 14/Nov/94 - raj.
    * No need to process if it is a macro library.
    */
   if ((refresh->rev_parttype) &&
            ((strcmp(refresh->rev_parttype, "M") == 0) ||
             (strcmp(refresh->rev_parttype, "m") == 0)))
   {
     _pdm_debug("file is of type macro library", 0);
     return(PDM_S_SUCCESS);
   }

  /* Make sure assy. struc. buffer is not empty. */
  if (!assy_struct_bufr)
     {
      _pdm_debug("assy_struct_bufr is NULL", 0);
      _pdm_debug("part must be atomic", 0);
      /*NumberOfBytes = sizeof(mod_env);
      status = gr$get_module_env(
                             msg = &msg,
                             sizbuf = &NumberOfBytes,
                             buffer = &mod_env,
                             nret = &BytesReceived
                            );
       di$give_pathname(osnum = mod_env.md_id.osnum, pathname = assy_path);
       strcat(assy_path, ":ASSEMBLY");
       status = PDUremove_assembly(assy_path, mod_env);
       _pdm_status("PDUremove_assembly", status);
        return(PDM_S_SUCCESS);*/
     }
  else if ((refresh->rev_parttype) && 
           ((strcmp(refresh->rev_parttype, "M") == 0) ||
            (strcmp(refresh->rev_parttype, "m") == 0)))
    {
    _pdm_debug("file is of type macro library", 0);
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

  if (PDM_debug_on)
     MEMprint_buffer("assy struct buffer", assy_struct_bufr, PDU_DEBUG_FILE);

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

  /* Check to see if checkout file exists locally */
  for (row = 0; row < file_bufr->rows; ++row)
      {
       PDUfill_in_string(
                         &file,
                         data_row[(file_bufr->columns * row) + file_col]
                        );

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
           file_already_open = FALSE;
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
              if (!status)
                {
                _pdm_debug("Try another permission", 0);
                status = ex$retrieve_module (
                                        filename = file,
                                        file_no = &index,
                                        ftype = EX_invisible,
                                        flag = EX_read_only,
                                        fstat = EX_default,
                                        type = EX_ACTINV,
                                        mount_name = mount_name,
                                        msg = &msg
                                       );
                if (!status)
                  {
                  _pdm_debug("ex$retrieve_module failed on <%s>", file);
                  _pdm_status("ex$retrieve_module", msg);
              
                  return(PDM_E_OPEN_FILE);
                  }
                file_already_open = TRUE;
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
               _pdm_debug("ex$get_invis_info_by_index failed on <%s>", file);

               return(PDM_E_OPEN_FILE);
              }

           mod_env.md_id.osnum = osnum;
           mod_env.md_id.objid = objid;

           /* JBP: Convert file if necessary */
           cvt_file = FALSE;
           di$give_pathname(
                            osnum = osnum,
                            pathname = old_origins_dir
                           );
           strcat(old_origins_dir, ":PDU:origins");
           status = di$ls(regexp = old_origins_dir, ptr = &count);
           _pdm_status("di$ls", status);
           if ((status == DIR_S_SUCCESS) || (count > 0))
             cvt_file = TRUE;
           di$give_pathname(
                            osnum = osnum,
                            pathname = old_parts_dir
                           );
           strcat(old_parts_dir, ":PDU:parts");
           status = di$ls(regexp = old_parts_dir, ptr = &count);
           _pdm_status("di$ls", status);
           if ((status == DIR_S_SUCCESS) || (count > 0))
             cvt_file = TRUE;
           
           if (cvt_file)
             {
             status = PDUcvt_20objspace_for_checkout(mod_env);
             _pdm_status("PDUcvt_20objspace", status);
             /* update cit information */
             status = PDMget_catno_partno( refresh->rev_catalog, 
                                           refresh->rev_partid,
                                           refresh->rev_revision,
                                           &catalog_no,
                                           &item_no
                                          );
              _pdm_status("PDMget_catno_partno", status);
              sscanf(catalog_no, "%d", &catno);
              sscanf(item_no, "%d", &itemno);
              status = PDUload_child_buffer(&child_bufr, mod_env);
              _pdm_status("PDUload_child_buffer", status);
              status = PDMupdate_set_members(refresh->rev_catalog,
                                             refresh->rev_partid, 
                                             refresh->rev_revision,
                                             catno, itemno,
                                             child_bufr, &citno, &new_set);
              _pdm_status("PDMupdate_set_members" ,status);
              if (child_bufr)
                {
                MEMclose(&child_bufr);
                child_bufr = NULL;
                }
              status = PDUload_dynamic_attrs(&mod_env, &dyn_attr, &dyn_data);
              _pdm_status("PDUload_dynamic_attrs", status);
              status = PDMinsert_citinfo(catno, itemno, new_set,
                                         dyn_attr, dyn_data, citno,
                                         "Y");
              if (dyn_attr)
                {
                MEMclose(&dyn_attr);
                dyn_attr = NULL;
                }
              if (dyn_data)
                {
                MEMclose(&dyn_data);
                dyn_data = NULL;
                }
              if (citno)
                {
                MEMclose(&citno);
                citno = NULL;
                }
              if (new_set)
                {
                MEMclose(&new_set);
                new_set = NULL;
                }
              status = PDMget_assembly_structure(refresh->rev_catalog,
                                                 refresh->rev_partid,
                                                 refresh->rev_revision,
                                                 MAX_LEVEL, &tmp_assy_bufr,
                                                 0);
              _pdm_status("PDMget_assembly_structure", status);
              assy_struct_bufr = tmp_assy_bufr;
              status = PDUstamp_PDU_design_file(mod_env);
              _pdm_status("PDUstamp_PDU_design_file", status);
             }

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
               /* Delete attach info directory in the checkout assembly */
               status = PDUupdate_attach_info(mod_env, NULL);
               _pdm_status("PDUupdate_attach_info", status);

               if (status != PDM_S_SUCCESS)
                  {
                   _pdm_debug("PDUdelete_attach_info failed", 0);

                   /* Close object file */
                   status = ex$close_module (
                                             index = index,
                                             flag = 0 | EX_ACTINV,
                                             ftype = EX_invisible
                                            );
                   _pdm_status ("ex$close_module", status);
                                                                           
                   return(PDM_E_COMPLETE_PART_CHECKOUT);
                  }

               /* Update part assembly structure from the database */
               status = PDUupdate_assembly_structure(
                                                     &mod_env,
                                                     TRUE,
                                                     assy_struct_bufr
                                                    );
               _pdm_status("PDUupdate_assembly_structure", status);

               if (status != PDM_S_SUCCESS)
                  {
                   _pdm_debug("PDUupdate_assembly_structure failed", 0);

                   /* Close object file */
                   status = ex$close_module (
                                             index = index,
                                             flag = 0 | EX_ACTINV,
                                             ftype = EX_invisible
                                            );
                   _pdm_status ("ex$close_module", status);
    
                   return(PDM_E_COMPLETE_PART_CHECKOUT);
                  }

               if (assy_struct_bufr == NULL)
               {
               status = ex$close_module (
                                         index = index,
                                         flag = 1 | EX_ACTINV,
                                         ftype = EX_invisible
                                        );
               if (file_already_open)
                 status = ex$close_module (
                                           index = index,
                                           flag = 0 | EX_ACTINV,
                                           ftype = EX_invisible
                                          );
               _pdm_status ("ex$close_module", status);
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

               PDMset_update_os_flag("P");

               return(PDM_S_SUCCESS);
               }

/* MJG 11/22/95 - TR 139528288 - Do not display edit assy form if revise assy
   form is displayed */
               if ((display_assembly) && 
                   (PDU_form_id != forms.rev_assy_form_id))
                   {
		   PDUmessage(PDS_M_PROCESSING_ASSY_DISP, 's');
                   if (assy_struct_bufr->rows > 1)
                      {
                       if (!PDU_edit_display)
                          {
                           _pdm_debug("edit display is set to OFF", 0);

                           /* Process previously saved assembly structure */
                           status = PDUprocess_assembly_display(
                                                                &mod_env,
                                                                NULL,
                                                                0,
                                                                0,
                                                                0
                                                               );
                           _pdm_status("PDUprocess_assembly_display", status);

                           if (status != PDM_S_SUCCESS)
                              {
                               /* Close object file */
                               status = ex$close_module (
                                                         index = index,
                                                         flag = 0 | EX_ACTINV,
                                                         ftype = EX_invisible
                                                        );
                               _pdm_status ("ex$close_module", status);

                               return(PDM_E_COMPLETE_PART_CHECKOUT);
                              }

                           /* Close and save PDU design file */
                           status = ex$close_module (
                                                     index = index,
                                                     flag = 1 | EX_ACTINV,
                                                     ftype = EX_invisible
                                                    );
                           if (file_already_open)
                           status = ex$close_module (
                                                     index = index,
                                                     flag = 0 | EX_ACTINV,
                                                     ftype = EX_invisible
                                                    );
                           _pdm_status ("ex$close_module", status);

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

                           PDMset_update_os_flag("P");

                           break;
                          }

                       /* Load assy. struct. buffer */
                       status = PDUload_assy_struct_buffer(
                                                           &mod_env,
                                                           &display_buffer,
                                                           -1,
                                                           NULL 
                                                          );
                       _pdm_status("PDUload_assy_struct_buffer", status);

                       if (status != PDM_S_SUCCESS)
                          {
                           _pdm_debug("PDUload_assy_struct_buffer failed", 0);

                           /* Close object file */
                           status = ex$close_module (
                                                     index = index,
                                                     flag = 0 | EX_ACTINV,
                                                     ftype = EX_invisible
                                                    );
                           _pdm_status ("ex$close_module", status);

                           return(PDM_E_COMPLETE_PART_CHECKOUT);
                          }
                       
                       if (display_buffer->rows > 1)
                          {
                           PDUmessage(PDS_M_LOADING_EDIT_ASSY_FORM, 's');
                           /* Display assembly structure for editing */
                           status = PDUassembly_display_form(
                                                             &mod_env,
                                                             display_buffer,
                                                             TRUE,
                                                             PDC_M_CHECKOUT 
                                                            );
                           _pdm_status("PDUassembly_display_form", status);

                           if (status != PDM_S_SUCCESS)
                              {
                               _pdm_debug("PDUassembly_display_form failed", 0);
                
                               /* Close object file */
                               status = ex$close_module (
                                                         index = index,
                                                         flag = 0 | EX_ACTINV,
                                                         ftype = EX_invisible
                                                        );
                               _pdm_status ("ex$close_module", status);

                               return(PDM_E_COMPLETE_PART_CHECKOUT);
                              }

                           /* Wait on user selection */
                           status = WaitForEvent();
                           _pdm_status("WaitForEvent", status);

                           if (!status)
                              {
                               _pdm_debug("assembly display form was cancelled", 0);

                               /* Process previously saved assembly structure */
                               status = PDUprocess_assembly_display(
                                                                    &mod_env,
                                                                    NULL,
                                                                    0,
                                                                    0,
                                                                    0
                                                                   );
                               _pdm_status("PDUprocess_assembly_display",
                                           status);

                               if (status != PDM_S_SUCCESS)
                                  {
                                   /* Close object file */
                                   status = ex$close_module (
                                                             index = index,
                                                             flag = 0 | EX_ACTINV,
                                                             ftype = EX_invisible
                                                            );
                                   _pdm_status ("ex$close_module", status);

                                   return(PDM_E_COMPLETE_PART_CHECKOUT);
                                  }

                               /* Close and save object file */
                               status = ex$close_module (
                                                         index = index,
                                                         flag = 1 | EX_ACTINV,
                                                         ftype = EX_invisible
                                                        );
                               if (file_already_open)
                                 status = ex$close_module (
                                                         index = index,
                                                         flag = 0 | EX_ACTINV,
                                                         ftype = EX_invisible
                                                         );
                               _pdm_status ("ex$close_module", status);

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

                              PDMset_update_os_flag("P");

                               break;
                              }
                          }
                      }
                  }

               else
                   {
                    /* Process previously saved assembly structure */
                    status = PDUprocess_assembly_display(
                                                         &mod_env,
                                                         NULL,
                                                         0,
                                                         0,
                                                         0
                                                        );
                    _pdm_status("PDUprocess_assembly_display", status); 

                    if (status != PDM_S_SUCCESS)
                       {
                        _pdm_debug("PDUprocess_assembly_display failed", 0);

                        /* Close object file */
                        status = ex$close_module (
                                                  index = index,
                                                  flag = 0 | EX_ACTINV,
                                                  ftype = EX_invisible
                                                 );
                        _pdm_status ("ex$close_module", status);

                        return(PDM_E_COMPLETE_PART_CHECKOUT);
                       }
                   }

               /* Close and save PDU design file */
               status = ex$close_module (
                                         index = index,
                                         flag = 1 | EX_ACTINV,
                                         ftype = EX_invisible
                                        );
               _pdm_status ("ex$close_module", status);
               if (file_already_open)
                 status = ex$close_module (
                                          index = index,
                                          flag = 0 | EX_ACTINV,
                                          ftype = EX_invisible
                                          );
               _pdm_status ("ex$close_module", status);
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

               PDMset_update_os_flag("P");

               break;
              }

             /* Update part assembly structure from the database */
             status = PDUupdate_assembly_structure(
                                                   &mod_env,
                                                   TRUE,
                                                   assy_struct_bufr
                                                  );
             _pdm_status("PDUupdate_assembly_structure", status);

             if (status != PDM_S_SUCCESS)
                {
                 _pdm_debug("PDUupdate_assembly_structure failed", 0);

                 /* Close object file */
                 status = ex$close_module (
                                           index = index,
                                           flag = 0 | EX_ACTINV,
                                           ftype = EX_invisible
                                          );
                 _pdm_status ("ex$close_module", status);
  
                 return(PDM_E_COMPLETE_PART_CHECKOUT);
                }

           /* Close object file */

           status = ex$close_module (
                                     index = index,
                                     flag = 1 | EX_ACTINV,
                                     ftype = EX_invisible
                                    );
           if (file_already_open)
           status = ex$close_module (
                                     index = index,
                                     flag = 0 | EX_ACTINV,
                                     ftype = EX_invisible
                                    );
           _pdm_status ("ex$close_module", status);
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

           PDMset_update_os_flag("P");

          }

     } /* end for row loop */

  /* Free up variables */
  if (file)
    free(file);

  if (display_buffer)
     MEMclose(&display_buffer);

  return(PDM_S_SUCCESS);
 }


/*
 * This function displays the assembly display structure prior to 
 * activating an assembly.
 */
IGRint  PDUdisplay_assembly_before_retrieve(filename)

 IGRchar                   *filename;

 {
  IGRlong                   status = PDM_S_SUCCESS;
  IGRint                    msg;
  struct                    GRmd_env  mod_env;
  IGRint                    index = 0;
  IGRchar                   mount_name[40];
  IGRshort                  major;
  IGRshort                  minor;
  GRobjid                   objid;
  IGRchar                   mach_type;
  GRobjid                   osid = NULL_OBJID;
  OMuword                   osnum;
  IGRint                    count = 0;
  IGRchar                   assy_path[DI_PATH_MAX];
  IGRint                    file_type;
  IGRlong                   NumberOfBytes, BytesReceived;
  MEMptr                    display_buffer = NULL;

  extern IGRshort           PDU_edit_display;


  _pdm_debug("In the PDUdisplay_assembly_before_retrieve function", 0);

  /* Check to see if user weshes to edit assembly display */
  if (!PDU_edit_display)
     {
      _pdm_debug("edit assembly display is set to OFF", 0);
      return(PDM_S_SUCCESS);
     }
 
  /* Get active module information */
  NumberOfBytes = sizeof(mod_env);
  status = gr$get_module_env(
                             msg = &msg,
                             sizbuf = &NumberOfBytes,
                             buffer = &mod_env,
                             nret = &BytesReceived
                            );

  /* Verify filename for part */
  status = PDUverify_file(filename);
  _pdm_status("PDUverify_file", status);

  if (status == PDM_E_FILE_NOT_FOUND)
     {
      _pdm_debug("file <%s> does not exist locally", filename);

      status = PDM_E_FILE_NOT_LOCAL;
      PDUmessage(status, 's');
      return(status);
     }

  /* Check to see if file is an OM file */
  status = ex$is_om_file(
                         filename = filename,
                         p_major = &major,
                         p_minor = &minor,
                         p_mach_type = &mach_type,
                         p_file_type = &file_type
                        );
  _pdm_status("ex$is_om_file", status);

  if (!status)
     {
      _pdm_debug("file <%s> is not an OM file", filename);
      return(PDM_S_SUCCESS);
     }

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
  if (!status)
     {
        _pdm_debug("retrieve_module failed on <%s>", filename);
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

  /* Construct path to <filename>:ASSEMBLY directory */
  di$give_pathname(
                   osnum = osnum,
                   pathname = assy_path
                  );

  strcat(assy_path, ":ASSEMBLY");

  /* Check to see if file is a PDU design file */
  status = di$ls(regexp = assy_path, ptr = &count);
  _pdm_status("di$ls", status);

  if (count <= 0)
     {
      _pdm_debug("no parts found in assembly", 0);

      /* Close object file */
      status = ex$close_module (
                                index = index,
                                flag = 0 | EX_ACTINV,
                                ftype = EX_invisible
                               );
      _pdm_status ("ex$close_module", status);

      return(PDM_S_SUCCESS);
     }

  /* Load assy. struct. buffer */
  status = PDUload_assy_struct_buffer(
                                      &mod_env,
                                      &display_buffer,
                                      -1,
                                      NULL
                                     );
  _pdm_status("PDUload_assy_struct_buffer", status);

  if (status != PDM_S_SUCCESS)
     {
      _pdm_debug("PDUload_assy_struct_buffer failed", 0);

      /* Close object file */
      status = ex$close_module (
                                index = index,
                                flag = 0 | EX_ACTINV,
                                ftype = EX_invisible
                               );
      _pdm_status ("ex$close_module", status);

      return(PDM_E_COMPLETE_PART_CHECKOUT);
     }

  if (!display_buffer)
     {
      _pdm_debug("display buffer is empty", 0);
      return(PDM_S_SUCCESS);
     }

  if (display_buffer->rows <= 0)
     {
      _pdm_debug("display buffer has no rows", 0);

      /* Free up variables */
      MEMclose(&display_buffer);
      display_buffer = NULL;

      return(PDM_S_SUCCESS);
     }

  /* Display assembly structure for editing */
  status = PDUassembly_display_form(
                                    &mod_env,
                                    display_buffer,
                                    TRUE,
                                    PDC_M_CHECKOUT
                                   );
  _pdm_status("PDUassembly_display_form", status);

  if (status == PDM_S_SUCCESS)
     {
      status = WaitForEvent();
      _pdm_status("WaitForEvent", status);

      if (!status)
         {
          _pdm_debug("assembly display form was cancelled", 0);

          /* Close object file */
          status = ex$close_module (
                                    index = index,
                                    flag = 0 | EX_ACTINV,
                                    ftype = EX_invisible
                                   );
          _pdm_status ("ex$close_module", status);

          return(PDM_E_CMD_CANCELLED);
         }

      /* Close and save PDU design file */
      status = ex$close_module (
                                index = index,
                                flag = 1 | EX_ACTINV,
                                ftype = EX_invisible
                               );
      _pdm_status ("ex$close_module", status);
     }

  else
      {
       _pdm_debug("PDUassembly_display_form failed", 0);
 
       return(PDM_E_CMD_CANCELLED);
      }

  /* Free up variables */
  if (display_buffer)
     MEMclose(&display_buffer);

  return(PDM_S_SUCCESS);
 }

int PDUconvert_file_before_review()
{
  IGRlong                   status = PDM_S_SUCCESS;
  IGRlong                   NumberOfBytes, BytesReceived;
  IGRint                    msg;
  IGRint                    index = 0;
  IGRint                    count = 0;
  IGRint                    file_type;
  IGRint                    catno, itemno;
  IGRint                    part_count = 0;
  struct                    GRmd_env  mod_env;
  IGRshort                  major;
  IGRshort                  minor;
  IGRshort                  file_already_open = FALSE;
  IGRshort                  cvt_file;
  IGRshort                  read_only = FALSE;
  IGRshort                  converted = TRUE;
  GRobjid                   objid;
  GRobjid                   osid = NULL_OBJID;
  OMuword                   osnum;
  IGRchar                   mach_type;
  IGRchar                   mount_name[40];
  IGRchar                   stamp_path[DI_PATH_MAX];
  IGRchar                   old_origins_dir[DI_PATH_MAX];
  IGRchar                   old_parts_dir[DI_PATH_MAX];
  IGRchar                   assembly_path[DI_PATH_MAX];
  IGRchar                   *file = NULL;
  IGRchar                   *catalog_no = NULL;
  IGRchar                   *item_no = NULL;
  IGRchar                   **parts = NULL;
  IGRchar                   *local_flag = NULL;
  IGRchar                   *save_filename = NULL;
  MEMptr                    child_bufr = NULL;
  MEMptr                    citno = NULL;
  MEMptr                    new_set = NULL;
  MEMptr                    assy_struct_bufr = NULL;
  MEMptr                    dyn_attr = NULL;
  MEMptr                    dyn_data = NULL;
  mode_t                    mode;

  extern  struct            PDUrefresh *refresh;
 
   _pdm_debug("in the function PDUconvert_file_before_review", 0);

   file = refresh->rev_filename;
   PDUfill_in_string(&save_filename, refresh->rev_filename);
   PDUfill_in_string(&refresh->act_filename, refresh->rev_filename);
 
   status = PDUcheck_file_permissions();
   _pdm_status("PDUcheck_file_permissions", status);
   if (!status)
     {
     _pdm_debug("file is read-only; changing permissions", 0);
     read_only = TRUE;
     mode = S_IRUSR | S_IRGRP | S_IROTH | S_IWUSR | S_IWGRP;
     status = PDUchange_file_permissions(file, mode);
     _pdm_status("PDUchange_file_permissions", status);
     if (status != PDM_S_SUCCESS)
       return(status);
     }
   PDUfill_in_string(&refresh->act_filename, save_filename);

  /* Get active module information */
  NumberOfBytes = sizeof(mod_env);
  status = gr$get_module_env(
                             msg = &msg,
                             sizbuf = &NumberOfBytes,
                             buffer = &mod_env,
                             nret = &BytesReceived
                            );

  /* Check to see if checkout file exists locally */
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
      file_already_open = FALSE;
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
         if (!status)
           {
           _pdm_debug("Try another permission", 0);
           status = ex$retrieve_module (
                                   filename = file,
                                   file_no = &index,
                                   ftype = EX_invisible,
                                   flag = EX_read_only,
                                   fstat = EX_default,
                                   type = EX_ACTINV,
                                   mount_name = mount_name,
                                   msg = &msg
                                  );
           if (!status)
             {
             _pdm_debug("ex$retrieve_module failed on <%s>", file);
             _pdm_status("ex$retrieve_module", msg);
         
             return(PDM_E_OPEN_FILE);
             }
           file_already_open = TRUE;
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
          _pdm_debug("ex$get_invis_info_by_index failed on <%s>", file);

          return(PDM_E_OPEN_FILE);
         }

      mod_env.md_id.osnum = osnum;
      mod_env.md_id.objid = objid;
      }
   else
      {
      _pdm_debug("file is not an OM file", 0);
      return(PDM_E_NOT_OM_FILE);
      }

   /* Convert file if necessary */
   cvt_file = FALSE;
   di$give_pathname(
		    osnum = osnum,
		    pathname = old_origins_dir
		   );
   strcat(old_origins_dir, ":PDU:origins");
   status = di$ls(regexp = old_origins_dir, ptr = &count);
   _pdm_status("di$ls", status);
   if ((status == DIR_S_SUCCESS) || (count > 0))
     cvt_file = TRUE;
   di$give_pathname(
		    osnum = osnum,
		    pathname = old_parts_dir
		   );
   strcat(old_parts_dir, ":PDU:parts");
   status = di$ls(regexp = old_parts_dir, ptr = &count);
   _pdm_status("di$ls", status);
   if ((status == DIR_S_SUCCESS) || (count > 0))
     cvt_file = TRUE;
   
   if (cvt_file)
     {
     converted = FALSE;
     status = PDUcvt_20objspace_for_checkout(mod_env);
     _pdm_status("PDUcvt_20objspace", status);
     /* update cit information */
     status = PDMget_catno_partno( refresh->rev_catalog, 
				   refresh->rev_partid,
				   refresh->rev_revision,
				   &catalog_no,
				   &item_no
				  );
      _pdm_status("PDMget_catno_partno", status);
      sscanf(catalog_no, "%d", &catno);
      sscanf(item_no, "%d", &itemno);
      status = PDUload_child_buffer(&child_bufr, mod_env);
      _pdm_status("PDUload_child_buffer", status);
      status = PDMupdate_set_members(refresh->rev_catalog,
				     refresh->rev_partid, 
				     refresh->rev_revision,
				     catno, itemno,
				     child_bufr, &citno, &new_set);
      _pdm_status("PDMupdate_set_members" ,status);
      if (child_bufr)
        {
	MEMclose(&child_bufr);
        child_bufr = NULL;
        }
      status = PDUload_dynamic_attrs(&mod_env, &dyn_attr, &dyn_data);
      _pdm_status("PDUload_dynamic_attrs", status);
      status = PDMinsert_citinfo(catno, itemno, new_set,
				 dyn_attr, dyn_data, citno,
				 "Y");
      if (dyn_attr)
        {
	MEMclose(&dyn_attr);
        dyn_attr = NULL;
        }
      if (dyn_data)
        {
	MEMclose(&dyn_data);
        dyn_data = NULL;
        }
      if (citno)
        {
	MEMclose(&citno);
        citno = NULL;
        }
      if (new_set)
        {
	MEMclose(&new_set);
        new_set = NULL;
        }
      status = PDMget_assembly_structure(refresh->rev_catalog,
					 refresh->rev_partid,
					 refresh->rev_revision,
					 MAX_LEVEL, &assy_struct_bufr,
					 0);
      _pdm_status("PDMget_assembly_structure", status);
      status = PDUstamp_PDU_design_file(mod_env);
      _pdm_status("PDUstamp_PDU_design_file", status);
     }
   else
     {
     /* JBP - check to see if first time 2.2 file is brought up in 
	3.0 */
     _pdm_debug("checking for 2.2 to 3.0 conversion", 0);
     di$give_pathname(osnum = osnum, pathname = assembly_path);
     strcat(assembly_path, ":ASSEMBLY");
     status = di$find(start_dir = assembly_path, regexp = "P*",
		      lines = &parts, ptr = &part_count, max_level = 1);
     _pdm_debug("part_count = <%d>", (char *)part_count);
     if (part_count > 0)
       {
       status = PDUstamp_PDU_design_file(mod_env);
       _pdm_status("PDUstamp_PDU_design_file", status);

       PDUstrip_dir_entry(parts[0]);
       status = PDUevaluate_exp(parts[0], "local_flag", &local_flag);
       _pdm_status("PDUevaluate_exp", status);
       if (status != PDM_S_SUCCESS)
	  {
          _pdm_debug("file has not been converted to 3.0", 0);
          converted = FALSE;
	  if (!PDMupdate_os_necessary())
	    {
	    /* problem with either file or database conversion to 2.2
	       was causing child numbers in database and file to be
	       out of sync. correct by updating child numbers in 
	       database. */
	    /* update cit information */
	    status = PDMget_catno_partno( refresh->rev_catalog, 
				   refresh->rev_partid,
				   refresh->rev_revision,
				   &catalog_no,
				   &item_no
				  );
	   _pdm_status("PDMget_catno_partno", status);
	   sscanf(catalog_no, "%d", &catno);
	   sscanf(item_no, "%d", &itemno);
	   status = PDUload_child_buffer(&child_bufr, mod_env);
	   _pdm_status("PDUload_child_buffer", status);
	   status = PDMupdate_set_members(refresh->rev_catalog,
				     refresh->rev_partid, 
				     refresh->rev_revision,
				     catno, itemno,
				     child_bufr, &citno, &new_set);
	   _pdm_status("PDMupdate_set_members" ,status);
	   if (child_bufr)
             {
	     MEMclose(&child_bufr);
             child_bufr = NULL;
             }
	 status = PDUload_dynamic_attrs(&mod_env, &dyn_attr, &dyn_data);
	   _pdm_status("PDUload_dynamic_attrs", status);
	   status = PDMinsert_citinfo(catno, itemno, new_set,
				 dyn_attr, dyn_data, citno,
				 "Y");
           if (dyn_attr)
             {
	     MEMclose(&dyn_attr);
             dyn_attr = NULL;
             }
           if (dyn_data)
             {
	     MEMclose(&dyn_data);
             dyn_data = NULL;
             }
           if (citno)
             {
	     MEMclose(&citno);
             citno = NULL;
             }
           if (new_set)
             {
	     MEMclose(&new_set);
             new_set = NULL;
             }
	   status = PDMget_assembly_structure(refresh->rev_catalog,
					 refresh->rev_partid,
					 refresh->rev_revision,
					 MAX_LEVEL, &assy_struct_bufr,
					 0);
	   _pdm_status("PDMget_assembly_structure", status);
	   }
	  }
       if (parts)
	 di$free(lines = parts, count = part_count);
	}
      }

    if (converted)
      {
      _pdm_debug("file does not need to be converted", 0);
      _pdm_debug("close and do not save object space", 0);
       status = ex$close_module (
                                 index = index,
                                 flag = 0 | EX_ACTINV,
                                 ftype = EX_invisible
                                );
       if (file_already_open)
         status = ex$close_module (
                                   index = index,
                                   flag = 0 | EX_ACTINV,
                                   ftype = EX_invisible
                                  );
       _pdm_status ("ex$close_module", status);

      _pdm_debug("make sure file is not still open", 0);
      status = PDUis_file_open(file);
      _pdm_status("PDUis_file_open", status);
  
      if (status)
        {
        _pdm_debug("file <%s> was left open", file);
        _pdm_debug("Construct file mount name", 0);
        strcpy(mount_name, ":");
        strcat(mount_name, file);
  
        _pdm_debug("mount_name = <%s>", mount_name);
  
        _pdm_debug("Get osnum of invis space", 0);
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
          _pdm_debug("Close and do not save object space", 0);
          status = ex$close_module (
                                       index = index,
                                       flag = 0 | EX_ACTINV,
                                       ftype = EX_invisible
                                 );
          _pdm_status ("ex$close_module", status);
          }
        }
       return(PDM_S_SUCCESS);
      }

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
       /* Delete attach info directory in the checkout assembly */
       status = PDUupdate_attach_info(mod_env, NULL);
       _pdm_status("PDUupdate_attach_info", status);

       if (status != PDM_S_SUCCESS)
	  {
	   _pdm_debug("PDUdelete_attach_info failed", 0);

	   /* Close object file */
	   status = ex$close_module (
				     index = index,
				     flag = 0 | EX_ACTINV,
				     ftype = EX_invisible
				    );
	   _pdm_status ("ex$close_module", status);
								   
	   return(PDM_E_RETRIEVE_ASSEMBLY);
	  }

       /* Update part assembly structure from the database */
       status = PDUupdate_assembly_structure(
					     &mod_env,
					     TRUE,
					     assy_struct_bufr
					    );
       _pdm_status("PDUupdate_assembly_structure", status);

       if (status != PDM_S_SUCCESS)
	  {
	   _pdm_debug("PDUupdate_assembly_structure failed", 0);

	   /* Close object file */
	   status = ex$close_module (
				     index = index,
				     flag = 0 | EX_ACTINV,
				     ftype = EX_invisible
				    );
	   _pdm_status ("ex$close_module", status);

	   return(PDM_E_RETRIEVE_ASSEMBLY);
	  }

        /* Process previously saved assembly structure */
        status = PDUprocess_assembly_display(
                                             &mod_env,
                                             NULL,
                                             0,
                                             0,
                                             0
                                            );
        _pdm_status("PDUprocess_assembly_display", status);

        if (status != PDM_S_SUCCESS)
           {
            _pdm_debug("PDUprocess_assembly_display failed", 0);

            /* Close object file */
            status = ex$close_module (
                                      index = index,
                                      flag = 0 | EX_ACTINV,
                                      ftype = EX_invisible
                                     );
            _pdm_status ("ex$close_module", status);

            return(PDM_E_RETRIEVE_ASSEMBLY);
           }

       _pdm_debug("close and save file", 0);
       status = ex$close_module (
				 index = index,
				 flag = 1 | EX_ACTINV,
				 ftype = EX_invisible
				);
       if (file_already_open)
         {
	 status = ex$close_module (
				   index = index,
				   flag = 0 | EX_ACTINV,
				   ftype = EX_invisible
				  );
         file_already_open = FALSE;
         }
       _pdm_status ("ex$close_module", status);
      }
    else
      {
       _pdm_debug("close and save file", 0);
       status = ex$close_module (
                                 index = index,
                                 flag = 1 | EX_ACTINV,
                                 ftype = EX_invisible
                                );
       if (file_already_open)
         status = ex$close_module (
                                   index = index,
                                   flag = 0 | EX_ACTINV,
                                   ftype = EX_invisible
                                  );
       _pdm_status ("ex$close_module", status);
       }

   status = PDM_S_SUCCESS;

   if (read_only)
     {
     _pdm_debug("resetting file permissions to READ-ONLY", 0);
     mode = S_IRUSR | S_IRGRP | S_IROTH;
     status = PDUchange_file_permissions(file, mode);
     _pdm_status("PDUchange_file_permissions", status);
     }

  return(status);
}

end implementation COpdu;
