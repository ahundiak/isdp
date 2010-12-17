class implementation COpdu;

#include        <string.h>
#include        <unistd.h>
#include        <PDUint.h>
#include        <PDUintdef.h>
#include        <refdef.h>
#include        <exdef.h>
#include        <exmacros.h>
#include        <expriv.h>
#include        <grio.h>
#include        <griodef.h>
#include        <griomacros.h>
#include        <msdef.h>
#include        <dpmacros.h>
#include        <dp.h>
#include        <dpdef.h>
#include        <igrdef.h>
#include        <grdpbmacros.h>
#include        <PDUuser.h>
#include        <PDUprompt.h>
#include        <PDUfile_def.h>
#include        <MEMerrordef.h>
#include        "DIdef.h"
#include        "DItypedef.h"
#include        "DIprims.h"
#include        "DIglob.h"
#include        "OMtypes.h"
#include        "PDUgrpart.h"
#include        "PDUerror.h"
#include        "partmacros.h"
#include        "part.h"
#include        "partdef.h"
#include        "PDUnode.h"
#include        "PDUstorage.h"
#include	"NFMerrordef.h"
#include	"WFexterns.h"

long PDUpost_to_database(cpr_catalogname, cpr_itemname, cpr_itemrev, 
                         wr_active_flag)
char *cpr_catalogname;
char *cpr_itemname;
char *cpr_itemrev;
short wr_active_flag;
  {
  long status;
  short never_checkedin = FALSE;
  int index = 0;
  int file_col = 0;
  int bufsiz;
  int msg;
  int responses[1];
  char *strings[1];
  char active_filename[DI_PATH_MAX];
  char answer[10];
  char output_var[100];
  char *cit_file = NULL;
  char *parttype = NULL;
  char *prompt_msg = NULL;
  char *act_file = NULL;
  char **om_data = NULL;
  struct GRmd_env mod_env;
  MEMptr filenames = NULL;
  MEMptr om_files = NULL;
  MEMptr reformatted_buffer = NULL;
  OMuword osnum;
  GRobjid objid;
  extern struct PDUuser *user;
  extern struct PDUrefresh *refresh;
  extern MEMptr PDU_child_buffer;
  extern MEMptr PDU_view_buffer;
  extern MEMptr PDU_dyn_attr_bufr;
  extern MEMptr PDU_dyn_data_bufr;
  extern MEMptr PDUchild_dyn_buffer;
  extern MEMptr PDU_param_buffer;

  _pdm_debug("PDUpost_to_database", 0);

  PDUmessage(PDC_M_UPDATE_DB, 'c');
  /* verify user is logged in */
  if (PDUnullstr(user->username))
    {
    _pdm_debug("user is not logged in", 0);
    return(PDM_E_USER_NOT_LOGGED_IN);
    }

  PDUclear_checkin_buffers();
  status = PDMrcheck_part_status(cpr_catalogname, cpr_itemname, cpr_itemrev);
  _pdm_status("PDMrcheck_part_status", status);

  if ((status == PDM_I_CHECKED_OUT_BY_ANOTHER_USER) || 
      (status == PDM_I_CHECKED_IN))
    return(status);
  else if (status == PDM_I_NEVER_CHECKED_IN)
    never_checkedin = TRUE;

  status = PDUverify_part('a');
  _pdm_status("PDUverify_part", status);

  if ((status == PDM_S_SUCCESS) && (strcmp(refresh->act_catalog,cpr_catalogname)
      == 0) && (strcmp(refresh->act_partid, cpr_itemname) == 0) && 
      (strcmp(refresh->act_revision, cpr_itemrev) == 0) && (!wr_active_flag))
    {
    wr_active_flag = TRUE;
    status = PDUverify_part('r');
    _pdm_status("PDUverify_part", status);
    if ((status == PDM_S_SUCCESS) && 
        (strcmp(refresh->act_catalog, refresh->rev_catalog) == 0) && 
        (strcmp(refresh->rev_partid, refresh->act_partid) == 0) && 
        (strcmp(refresh->rev_revision, refresh->act_revision) == 0))
      {
      strcpy(output_var, refresh->act_filename);
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
       if ((strcmp(answer, "Y") == 0) || (strcmp(answer, "y") == 0))
         {
         responses[0] = STRING;
         strings[0] = "y";
         PDUprepare_queue(responses, strings, 1);
         msg = ex$save_module(ftype = EX_visible, 
                              filename = refresh->act_filename);
         _pdm_status("ex$save_module", msg);
         return(PDM_S_SUCCESS);
         }
       }
     }

  if (wr_active_flag)
    {
    _pdm_debug("process from active part",0);
    status = PDUverify_files_exist_locally(cpr_catalogname, 
                                           cpr_itemname, cpr_itemrev,
                                           &filenames);
    _pdm_status("PDMverify_files_exist_locally", status);
    if (status != PDM_S_SUCCESS)
      return(status);

     /* validate access for part */
     status = PDMvalidate_user_access("PDMCheck In Part", NULLSTR, 
                                      cpr_catalogname, NULLSTR, 
                                      cpr_itemname, cpr_itemrev);
     _pdm_status("PDMvalidate_user_access", status);
     if (status != PDM_S_SUCCESS)
       return(status);
     PDUfill_in_string(&refresh->rev_catalog, cpr_catalogname);
     PDUfill_in_string(&refresh->rev_partid, cpr_itemname);
     PDUfill_in_string(&refresh->rev_revision, cpr_itemrev);
     _pdm_debug("cpr_catalogname = <%s>", cpr_catalogname);
     _pdm_debug("cpr_itemname = <%s>", cpr_itemname);
     _pdm_debug("cpr_itemrev = <%s>", cpr_itemrev);
     status = PDUget_parttype(cpr_catalogname, cpr_itemname, cpr_itemrev,
                              &parttype);
     _pdm_status("PDUget_parttype", status);
     PDUfill_in_string(&refresh->rev_parttype, parttype);
     if ((strcmp(parttype, "M") != 0) && (strcmp(parttype, "m") != 0))
     {
     bufsiz = sizeof(mod_env);
     gr$get_module_env(msg = &msg, sizbuf = bufsiz, buffer = &mod_env);
     if (PDUis_PDU_design_file(&mod_env))
       _pdm_debug("File is PDU_design_file", 0);
     else if (filenames->rows == 1)
       {
       _pdm_debug("Only one file for part. Stamp file as a PDU design file", 0);
       status = PDUstamp_PDU_design_file(mod_env);
       _pdm_status("PDUstamp_PDU_design_file", status);
       }
     else
       {
       di$give_pathname(osnum = mod_env.md_id.osnum, 
                        pathname = active_filename);
       PDUfill_in_string(&act_file, active_filename);
       /* strip of colon */
       act_file = act_file + 1;
       _pdm_debug("active_filename = <%s>", act_file);
      status = PDUfind_PDU_stamp_files(filenames, act_file,&om_files, 
                                       &mod_env, &index);
      _pdm_status("PDUfind_PDU_stamp_files", status);

       if (status != PDM_S_SUCCESS)
         return(status);
       if ((om_files->rows == 1) && (index != -1))
         {
         status = MEMbuild_array(om_files);
         _pdm_status("MEMbuild_array", status);
         if (status != MEM_S_SUCCESS)
          return(PDM_E_BUILD_ARRAY);
         om_data = (char **)om_files->data_ptr; 
         status = PDUget_buffer_col(om_files, "n_cofilename", &file_col);
         _pdm_status("PDUget_buffer_col", status);
         if (status != PDM_S_SUCCESS)
          return(status);
         PDUfill_in_string(&cit_file, om_data[file_col]);
         }
       else if (om_files->rows == 1)
         {
         _pdm_debug("file needs to be opened and stamped", 0);
         status = MEMbuild_array(om_files);
         _pdm_status("MEMbuild_array", status);
         if (status != MEM_S_SUCCESS)
           return(PDM_E_BUILD_ARRAY);
         om_data = (char **)om_files->data_ptr; 
         status = PDUget_buffer_col(om_files, "n_cofilename", &file_col);
         _pdm_status("PDUget_buffer_col", status);
         if (status != PDM_S_SUCCESS)
           return(status);
         PDUfill_in_string(&cit_file, om_data[file_col]);
         status = PDUopen_design_file_invisibly(cit_file, &index, &osnum, &objid);
         _pdm_status("PDUopen_design_file_invisibly", status);
         if (status != PDM_S_SUCCESS)
           return(status);
         mod_env.md_id.osnum = osnum;
         mod_env.md_id.objid = objid;
         status = PDUstamp_PDU_design_file(mod_env);
         _pdm_status("PDUstamp_PDU_design_file", status);
         }
       else
         {
         _pdm_debug("Display list of files", 0);
         status = PDUdisplay_list_of_om_files(om_files, &cit_file);
         _pdm_status("PDUdisplay_list_of_om_files", status);
         if (status != PDM_S_SUCCESS)
           return(status);
         status = PDUopen_design_file_invisibly(cit_file, &index, &osnum, 
                                               &objid);
         _pdm_status("PDUopen_design_file_invisibly", status);
         if (status != PDM_S_SUCCESS)
           return(status);
         mod_env.md_id.osnum = osnum;
         mod_env.md_id.objid = objid;
         status = PDUstamp_PDU_design_file(mod_env);
         _pdm_status("PDUstamp_PDU_design_file", status);
         }
       }
     status = PDUload_file_assembly_information(mod_env);
     _pdm_status("PDUload_file_assembly_information", status);
     if (status != PDM_S_SUCCESS)
       return(status);
     } 
     }
  else
    {
    status = PDMcheck_if_checkedin(cpr_catalogname, cpr_itemname, cpr_itemrev);
    _pdm_status("PDMcheck_if_checkedin", status);
    if ((status == PDM_S_SUCCESS) || (status == PDM_E_NOTCHECK_IN) ||
        (status == PDM_E_PART_CHECKED_OUT) || 
        (status == PDM_E_ASSEMBLY_CHECKED_OUT))
      _pdm_debug("Part is checked out or never been checked in");
    else if (status == PDM_E_NOTCHECK_OUT)
      return(PDM_I_CHECKED_IN);
    else
      return(status);
    status = PDUverify_files_exist_locally(cpr_catalogname, 
                                           cpr_itemname, cpr_itemrev,
                                           &filenames);
     _pdm_debug("PDUverify_files_exist_locally", status);
    if (status != PDM_S_SUCCESS)
      return(status);
    /* validate access for part */
    status = PDMvalidate_user_access("PDMCheck In Part", NULLSTR, 
                                     cpr_catalogname, NULLSTR, cpr_itemname, 
                                     cpr_itemrev);
    _pdm_status("PDMvalidate_user_access", status);
 
    if (status != PDM_S_SUCCESS)
      {
      PDUmessage(status, 's');
      return(status);
      }

    PDUfill_in_string(&refresh->rev_catalog, cpr_catalogname);
    PDUfill_in_string(&refresh->rev_partid, cpr_itemname);
    PDUfill_in_string(&refresh->rev_revision, cpr_itemrev);
    status = PDUget_parttype(cpr_catalogname, cpr_itemname, cpr_itemrev, 
                             &parttype);
    _pdm_status("PDUget_parttype", status);

    PDUfill_in_string(&refresh->rev_parttype, parttype);
    if ((strcmp(parttype, "M") != 0) && (strcmp(parttype, "m") != 0))
    {
    status = PDUfind_PDU_stamp_files(filenames, NULL, &om_files, &mod_env, 
                                     &index);
    _pdm_status("PDUfind_PDU_stamp_files", status);

    if (status != PDM_S_SUCCESS)
      return(status);
  
    if ((om_files) && (om_files->rows > 0))
      {
      if ((om_files->rows == 1) && (index != -1))
        {
        status = MEMbuild_array(om_files);
        _pdm_status("MEMbuild_array", status);
        if (status != MEM_S_SUCCESS)
          return(PDM_E_BUILD_ARRAY);
        om_data = (char **)om_files->data_ptr; 
        status = PDUget_buffer_col(om_files, "n_cofilename", &file_col);
        _pdm_status("PDUget_buffer_col", status);
        if (status != PDM_S_SUCCESS)
          return(status);
        PDUfill_in_string(&cit_file, om_data[file_col]);
        }
     else if (om_files->rows == 1)
       {
       _pdm_debug("file needs to be opened and stamped", 0);
       status = MEMbuild_array(om_files);
       _pdm_status("MEMbuild_array", status);
       if (status != MEM_S_SUCCESS)
         return(PDM_E_BUILD_ARRAY);
       om_data = (char **)om_files->data_ptr; 
       status = PDUget_buffer_col(om_files, "n_cofilename", &file_col);
       _pdm_status("PDUget_buffer_col", status);
       if (status != PDM_S_SUCCESS)
         return(status);
       PDUfill_in_string(&cit_file, om_data[file_col]);
	_pdm_debug("citfile =<%s>", cit_file);
       status = PDUopen_design_file_invisibly(cit_file, &index, &osnum, &objid);
       _pdm_status("PDUopen_design_file_invisibly", status);
       _pdm_debug("After PDUopen_design_file_invisibly index = <%d>", index);
       if (status != PDM_S_SUCCESS)
         return(status);
       mod_env.md_id.osnum = osnum;
       mod_env.md_id.objid = objid;
       status = PDUstamp_PDU_design_file(mod_env);
       _pdm_status("PDUstamp_PDU_design_file", status);
       _pdm_debug("After PDUstamp_PDU_design_file index = <%d>", index);
       }
     else
       {
       _pdm_debug("Display list of files", 0);
       status = PDUdisplay_list_of_om_files(om_files, &cit_file);
       _pdm_status("PDUdisplay_list_of_om_files", status);
       if (status != PDM_S_SUCCESS)
         return(status);
       status = PDUopen_design_file_invisibly(cit_file, &index, &osnum, &objid);
       _pdm_status("PDUopen_design_file_invisibly", status);
       if (status != PDM_S_SUCCESS)
         return(status);
       mod_env.md_id.osnum = osnum;
       mod_env.md_id.objid = objid;
       status = PDUstamp_PDU_design_file(mod_env);
       _pdm_status("PDUstamp_PDU_design_file", status);
       }
      status = PDUload_file_assembly_information(mod_env);
      _pdm_status("PDUload_file_assembly_information", status);
      if (status != PDM_S_SUCCESS)
        return(status);
	_pdm_debug("After PDUload_file_assembly_information index = <%d>", index);
      status = ex$close_module(index = index, flag = 1 | EX_ACTINV,
                               ftype = EX_invisible);
      _pdm_status("ex$close_module", status);
      }
     }
    }
  if (PDUchild_dyn_buffer)
    {
    status = PDMrecreate_validated_dyn_databufr(PDUchild_dyn_buffer,
                                                &reformatted_buffer);
    _pdm_status("PDMrecreate_validated_dyn_data_bufr", status);
    if (status != PDM_S_SUCCESS)
      {
      PDUmessage_trans(status, 's');
      return(status);
      }
    }
  PDUload_exec_structure("", refresh->rev_catalog, refresh->rev_partid, 
                         refresh->rev_revision, "", "", "", 0, 0);
  status = PDMpost_to_database(PDU_child_buffer, PDU_view_buffer, 
                               PDU_dyn_attr_bufr, PDU_dyn_data_bufr, 
                               PDU_param_buffer, reformatted_buffer);
  _pdm_status("PDMpost_to_database", 0);
  refresh->command = PDC_M_CHECKIN;
  PDUmessage_trans(status, 's');
  status = PDMvalidate_user_access("PDMCheck Out Part", NULLSTR, 
                                    cpr_catalogname, NULLSTR, 
                                    cpr_itemname, cpr_itemrev);
   _pdm_status("PDMvalidate_user_access", status);
  refresh->command = PDC_M_CHECKOUT;
  PDUmessage_trans(status, 's');
  if (never_checkedin)
    {
    _pdm_debug("set to state again for parts which had never been checked in", 
     0);
    refresh->command = PDC_M_CHECKOUT;
    PDUmessage_trans(status, 's');
    }
 /* ALR  TR139415739 */
  if (status != PDM_S_SUCCESS)
   {
     if (status == NFM_E_NOT_CO_USER)
       status = PDM_E_ANOTHER_USER;
     PDUmessage(status,'s');
   }
  else
   {
     PDUmessage(status,'s');
     sleep(3);
   }
  return(status);
  }
      
int PDUfind_PDU_stamp_files(filenames, act_file, om_files, spr_mod_env, index)

  MEMptr filenames;
  char *act_file;
  MEMptr *om_files;
  struct GRmd_env *spr_mod_env;
  int *index;

  {
  int status;
  int i;
  int filename_col = 0;
  int file_type;
  int msg;
  int file_open = FALSE;
  short major;
  short minor;
  long  NumberOfBytes, BytesReceived;
  char  mach_type;
  char  mount_name[40];
  char  full_path[DI_PATH_MAX];
  char *file = NULL;
  char *row = NULL;
  char **filenames_data = NULL;
  GRobjid osid = NULL_OBJID;
  OMuword osnum;
  GRobjid objid;
  struct GRmd_env active_mod_env;
  extern struct PDUuser *user;

  _pdm_debug("PDUfind_PDU_stamp_files", 0);

  /* Get active module information */
  NumberOfBytes = sizeof(struct GRmd_env);

  status = gr$get_module_env(
                             msg = &msg,
                             sizbuf = &NumberOfBytes,
                             buffer = &active_mod_env,
                             nret = &BytesReceived
                            );

  status = gr$get_module_env(
                             msg = &msg,
                             sizbuf = &NumberOfBytes,
                             buffer = spr_mod_env,
                             nret = &BytesReceived
                            );

  if (filenames == NULL)
    return(PDM_I_NO_FILES_FOUND);
  else if (filenames->rows == 0)
    return(PDM_I_NO_FILES_FOUND);

  if (PDM_debug_on)
    MEMprint_buffer("filenames", filenames, PDU_DEBUG_FILE);

  status = MEMbuild_array(filenames);
  _pdm_status("MEMbuild_array", status);

  if (status != MEM_S_SUCCESS)
    return(PDM_E_BUILD_ARRAY);

  status = PDUget_buffer_col(filenames, "n_cofilename", &filename_col);
  _pdm_status("PDUget_buffer_col", status);
  if (status != PDM_S_SUCCESS)
    return(status);

  filenames_data = (char **)filenames->data_ptr;
  for ( i = 0; i < filenames->rows; i ++)
    {
    if ((act_file) && (strcmp(act_file, "") != 0) && (strcmp(act_file, 
        filenames_data[(filenames->columns * i) + filename_col]) == 0))
      {
      _pdm_debug("active_file found", 0);
      if (PDUis_PDU_design_file(&active_mod_env))
        {
        if (*om_files)
          {
          MEMclose(om_files);
          *om_files = NULL;
          }
        PDMopen_buffer(12, om_files);
        row = (char *)malloc(sizeof(char) * (*om_files)->row_size);
        memset(row, NULL, (*om_files)->row_size);
        sprintf(row, "%s\1", act_file);
        status = MEMwrite(*om_files, row);
        _pdm_status("MEMwrite", status);
        if ( status != MEM_S_SUCCESS)
          return(PDM_E_WRITE_BUFFER);
        free(row);
        break;
        }
      else if (PDUis_PDU_file(active_mod_env))
        {
        if (*om_files == NULL)
          PDMopen_buffer(12, om_files);
        row = (char *)malloc(sizeof(char) * (*om_files)->row_size);
        memset(row, NULL, (*om_files)->row_size);
        sprintf(row, "%s\1", act_file);
        status = MEMwrite(*om_files, row);
        _pdm_status("MEMwrite", status);
        if ( status != MEM_S_SUCCESS)
          return(PDM_E_WRITE_BUFFER);
        free(row);
        }
       else
        {
        if (*om_files == NULL)
          PDMopen_buffer(12, om_files);
        row = (char *)malloc(sizeof(char) * (*om_files)->row_size);
        memset(row, NULL, (*om_files)->row_size);
        sprintf(row, "%s\1", act_file);
        status = MEMwrite(*om_files, row);
        _pdm_status("MEMwrite", status);
        if ( status != MEM_S_SUCCESS)
          return(PDM_E_WRITE_BUFFER);
        free(row);
        }
      continue;
      }
    PDUfill_in_string(&file, filenames_data[(filenames->columns * i ) +
                      filename_col]);
    status = ex$is_om_file(filename = file, p_major = &major, p_minor = &minor,
                           p_mach_type = &mach_type, p_file_type = &file_type);
    _pdm_status("ex$is_om_file", status);
    if (status)
      {
      _pdm_debug("file <%s>: is an OM file", file);
      file_open = ex$is_file_open(name = file);
      _pdm_status("ex$is_file_open", file_open);
      if (file_open)
        {
        _pdm_debug("file is open", 0);
        status = om$os_name_to_number(osname = file, p_osnum = &osnum);
        _pdm_status("om$os_name_to_number", status);
        if (status != 1)
          {
          strcpy(full_path, user->wrkst_cwd);
          strcat(full_path, "/");
          strcat(full_path, file);
          status = om$os_name_to_number(osname = full_path, p_osnum = &osnum);
          _pdm_status("om$os_name_to_number", status);
          status = ex$is_invis(mod_osnum = osnum, index = index);
          _pdm_status("ex$is_invis", status);
          }
        }
      else
        {
        strcpy(mount_name, "");
        strcpy(mount_name, ":");
        strcat(mount_name, file);
        _pdm_debug("mount_name = <%s>", mount_name);

        /* get osnum of invis space */
        status = ex$retrieve_module(filename = file, file_no = index,
                                    ftype = EX_invisible, flag = EX_read_write,
                                    fstat = EX_default, type = EX_ACTINV,
                                    mount_name = mount_name, msg = &msg);
        _pdm_status("ex$retrieve_module", status);

        if (!status)
           return(PDM_E_OPEN_FILE);
        }

      /* open object space */
      status = ex$get_invis_info_by_index(index = *index, mod_osnum = &osnum,
                                          mod_id = &objid, filed_id = &osid);
      _pdm_status("ex$get_invis_info_by_index", status);
      if (!status)
        return(PDM_E_OPEN_FILE);

      spr_mod_env->md_id.osnum = osnum;
      spr_mod_env->md_id.objid = objid;

      if (PDUis_PDU_design_file(spr_mod_env))
        {
        if (*om_files)
          {
          MEMclose(om_files);
          *om_files = NULL;
          }
        PDMopen_buffer(12, om_files);
        row = (char *)malloc(sizeof(char) * (*om_files)->row_size);
        memset(row, NULL, (*om_files)->row_size);
        sprintf(row, "%s\1", file);
        status = MEMwrite(*om_files, row);
        _pdm_status("MEMwrite", status);
        if ( status != MEM_S_SUCCESS)
          return(PDM_E_WRITE_BUFFER);
        if (file_open)
          {
          _pdm_debug("setting index", 0);
          *index = -1;
          }
        free(row);
        break;
        }
      else if (PDUis_PDU_file(*spr_mod_env))
        {
        if (*om_files == NULL)
          PDMopen_buffer(12, om_files);
        row = (char *)malloc(sizeof(char) * (*om_files)->row_size);
        memset(row, NULL, (*om_files)->row_size);
        sprintf(row, "%s\1", file);
        status = MEMwrite(*om_files, row);
        _pdm_status("MEMwrite", status);
        if ( status != MEM_S_SUCCESS)
          return(PDM_E_WRITE_BUFFER);
        if (!file_open)
          {
          status = ex$close_module(index = *index, flag = 0 | EX_ACTINV,
                                   ftype = EX_invisible);
          _pdm_status("ex$close_module", status);
          }
        free(row);
        *index = -1;
        }
      else
        {
        if (*om_files == NULL)
          PDMopen_buffer(12, om_files);
        row = (char *)malloc(sizeof(char) * (*om_files)->row_size);
        memset(row, NULL, (*om_files)->row_size);
        sprintf(row, "%s\1", file);
        status = MEMwrite(*om_files, row);
        _pdm_status("MEMwrite", status);
        if ( status != MEM_S_SUCCESS)
          return(PDM_E_WRITE_BUFFER);
        if (!file_open)
          {
          status = ex$close_module(index = *index, flag = 0 | EX_ACTINV,
                                   ftype = EX_invisible);
          _pdm_status("ex$close_module", status);
          }
        free(row);
        *index = -1;
        }
      }
    }

  return(PDM_S_SUCCESS);
  }

int PDUis_PDU_design_file(spr_mod_env)
struct GRmd_env *spr_mod_env;

  {
  int count = 0;
  long status;
  char stamp_path[DI_PATH_MAX];

  _pdm_debug("In PDUis_PDU_design_file", 0);
  di$give_pathname(osnum = spr_mod_env->md_id.osnum, pathname = stamp_path);
  strcat(stamp_path, ":PDU_DESIGN_FILE");
  _pdm_debug("stamp_part = <%s>", stamp_path);
  /* check to see if file is stamped */
  status = di$ls(regexp = stamp_path, ptr = &count);
  _pdm_status("di$ls", status);
  if ((status == DIR_S_SUCCESS) && (count > 0))
    return(1);

  return(0);
  }

int PDUopen_design_file_invisibly(filename, index, osnum, objid)

char *filename;
int *index;
OMuword *osnum;
GRobjid *objid;

  {
  int status;
  int msg;
  int file_open = FALSE;
  char  mount_name[40];
  char  full_path[DI_PATH_MAX];
  GRobjid osid = NULL_OBJID;
  extern struct PDUuser *user;

  _pdm_debug("PDUopen_design_file_invisibly", 0);

  strcpy(mount_name, ":");
  strcat(mount_name, filename);

  file_open = ex$is_file_open(name = filename);
  _pdm_status("ex$is_file_open", file_open);
  if (file_open)
    {
    _pdm_debug("file is open", 0);
    status = om$os_name_to_number(osname = filename, p_osnum = osnum);
    _pdm_status("om$os_name_to_number", status);
    if (status != 1)
      {
      strcpy(full_path, user->wrkst_cwd);
      strcat(full_path, "/");
      strcat(full_path, filename);
      status = om$os_name_to_number(osname = full_path, p_osnum = osnum);
      _pdm_status("om$os_name_to_number", status);
      status = ex$is_invis(mod_osnum = *osnum, index = index);
      _pdm_status("ex$is_invis", status);
      }
    }
  else
    {
    status = ex$retrieve_module(filename = filename, file_no = index,
                                ftype = EX_invisible, flag = EX_read_write,
                                fstat = EX_default, type = EX_ACTINV,
                                mount_name = mount_name, msg = &msg);
    _pdm_status("ex$retrieve_module", status);

    if (!status)
      return(PDM_E_OPEN_FILE);
     }

  /* open object space */
  status = ex$get_invis_info_by_index(index = *index, mod_osnum = osnum,
                                      mod_id = objid, filed_id = &osid);
  _pdm_status("ex$get_invis_info_by_index", status);
  if (!status)
    return(PDM_E_OPEN_FILE);

  return(PDM_S_SUCCESS);
  }
  
int PDUdisplay_list_of_om_files(om_files, filename)

MEMptr om_files;
char **filename;

  {
  int status;
  extern MEMptr PDU_ret_bufr;
  extern char *PDU_checkin_file;

  _pdm_debug("In PDUdisplay_list_of_om_files", 0);

  if (PDU_ret_bufr)
    {
    MEMclose(&PDU_ret_bufr);
    PDU_ret_bufr = NULL;
    }

  status = MEMsplit_copy_buffer(om_files, &PDU_ret_bufr, 1);
  _pdm_status("MEMsplit_copy_buffer", status);
  if (status != MEM_S_SUCCESS)
    return(PDM_E_COPY_BUFFER);

  status = PDUdisplay_checkin_files();
  _pdm_status("PDUdisplay_checkin_files", status);

  PDUmessage(PDM_I_FILE_DEFASSEM_STRUCT, 's');
  status = WaitForEvent();
  _pdm_status("WaitForEvent", status);
  if (!status)
    return(PDM_E_CMD_CANCELLED);
  else if (PDU_checkin_file == NULL)
    return(PDM_E_CMD_CANCELLED);
  else if (strcmp(PDU_checkin_file, "") == 0)
    return(PDM_E_CMD_CANCELLED);
   
  PDUfill_in_string(filename, PDU_checkin_file);
  _pdm_debug("filename = <%s>", *filename);

  return(PDM_S_SUCCESS);
  }

int PDUload_file_assembly_information(spr_mod_env)

struct GRmd_env spr_mod_env;

  {
  int status;
  int count = 0;
  struct PDUpart_node *parametric_ids = NULL;
  struct PDUpart_node *head = NULL;
  extern int PDU_dyn_index;
  extern MEMptr PDU_child_buffer;
  extern MEMptr PDU_view_buffer;
  extern MEMptr PDU_dyn_attr_bufr;
  extern MEMptr PDU_dyn_data_bufr;
  extern MEMptr PDUchild_dyn_buffer;
  extern MEMptr PDU_param_buffer;
  extern struct PDUcat_node *PDU_param_cat_list;

  _pdm_debug("PDUload_file_assembly_information", 0);
 
  status = PDUget_all_parametric_ids(spr_mod_env.md_id.osnum, &parametric_ids,
                                     &count);
  _pdm_status("PDUget_all_parametric_ids", status);

  if (count > 0)
    {
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

    status = PDUprepare_param_cats_list(&spr_mod_env, &PDU_param_cat_list);
    _pdm_status("PDUprepare_param_cats_list", status);

    if (status != PDM_S_SUCCESS)
      return(status);

    PDU_dyn_index = 1;
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
    if (PDU_child_buffer)
      {
      MEMclose(&PDU_child_buffer);
      PDU_child_buffer = NULL;
      }

    status = PALchekin(&spr_mod_env);
    _pdm_status("PALchekin", status);

    if (!status)
      return(PDM_E_LOAD_FILE_INFO);
    }

  status = PDUload_child_buffer(&PDU_child_buffer, spr_mod_env);
  _pdm_status("PDUload_child_buffer", status);
  if (status != PDM_S_SUCCESS)
    return(status);
      
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
  status = PDUload_dynamic_attrs(&spr_mod_env, &PDU_dyn_attr_bufr, 
                                               &PDU_dyn_data_bufr);
  _pdm_status("PDUload_dynamic_attrs", status);
  if (status != PDM_S_SUCCESS)
    return(status);

  if (PDU_view_buffer)
    {
    MEMclose(&PDU_view_buffer);
    PDU_view_buffer = NULL;
    }
  status = PDUload_view_info(spr_mod_env.md_id.objid, spr_mod_env.md_id.osnum,
                             &PDU_view_buffer);
  _pdm_status("PDUload_view_info", status);
  
  if ((status != PDM_S_SUCCESS) && (status != PDM_I_ORIGIN_NOT_FOUND))
    return(status);
  else if (status == PDM_I_ORIGIN_NOT_FOUND)
    _pdm_debug("No origins found", 0);

  return(PDM_S_SUCCESS);
  }


end implementation COpdu;
