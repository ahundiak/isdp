class implementation COpdu;

#if ! defined(__sgi)
#include        "unistd.h"
#endif
#include        "stdio.h"
#include        "ciexecmacros.h"
#include        "expriv.h"
#include        "DIdef.h"
#include        "DItypedef.h"
#include        "DIprims.h"
#include        "DIglob.h"
#include	<grdpbdef.h>
#include	<grdpbmacros.h>
#include	<nddef.h>
#include	<acdef.h>
#include	<acmacros.h>
#include	<macro.h>
#include	<PDUpart.h>
#include	<PDUint.h>
#include	<PDUintdef.h>
#include	<PDUparamdef.h>
#include	<PDUfile_def.h>
#include        <string.h>
#include        <ACdb_info.h>
#include	<MEMerrordef.h>
#include        <PDUmacros.h>
#include        <PDUnode.h>
#include        <PDUuser.h>
#include        <expression.h>
#include        <errno.h>
#include        <sys/errno.h>
#include        <refmacros.h>
#include        <sys/stat.h>

#define	NULL_COL	" "

/* global orientations for writing child buffer */
IGRchar	coordsys_orientation[PDU_K_ORIENTATION_LEN];
IGRchar	default_orientation[100];
IGRchar	*ORIENTATION;

from ACdb_info import ACget_db_info;
from ACcpx_defn import ACgive_temp_desc, ACgive_feet_desc, ACgive_name;
from NDnode import NDget_objects, NDgive_structure;
from NDmacro import ACgive_structure;
from ACcpx import find_macro;
from module import mod_info;

struct GRmd_env ModuleInfo;
/* part area global */
extern struct PDUpart   *part;
extern struct PDUuser   *user;
extern char *PDU_macro_dyn_list[50];
extern int  PDU_macro_dyn_num;
extern char *PDU_save_filename;

PDUget_module_env (objid, osnum)
  GRobjid       objid;
  GRspacenum    osnum;
  {
  long msg,NumberOfBytes,BytesReceived;

  NumberOfBytes = sizeof(ModuleInfo);
  gr$get_module_env( msg = &msg,
                     sizbuf = &NumberOfBytes,
                     buffer = &ModuleInfo,
                     nret = &BytesReceived);
  _pdm_status ("gr$get_module_env", msg);

  if ( osnum != NULL )
     ModuleInfo.md_id.osnum = osnum;
  if ( objid != NULL_OBJID )
     ModuleInfo.md_id.objid = objid;
  return(PDM_S_SUCCESS);        /* return(PDM_S_SUCCESS)        APOGEE */
  }

IGRint PDUedit_macro_library()

  {
  IGRint status;
  extern IGRchar *PDU_macro_catalog;
  extern IGRchar *PDU_macro_partid;
  extern IGRchar *PDU_macro_partrev;
  extern IGRchar *PDU_macro_name;
  extern IGRchar *PDU_macro_library;
  extern struct  PDUrefresh *refresh;
  long msg,NumberOfBytes,BytesReceived;
  struct GRid header;
  extern short PDU_checkin_lib;

  _pdm_debug("In PDUedit_macro_library", 0);

   /* call function to edit macro header */
  NumberOfBytes = sizeof(ModuleInfo);
  gr$get_module_env( msg = &msg,
		     sizbuf = &NumberOfBytes,
		     buffer = &ModuleInfo,
		     nret = &BytesReceived);
  _pdm_status ("gr$get_module_env", msg);

   _pdm_debug("macro name = <%s>", PDU_macro_name);
   status = GetMacroHeaderGivenName(PDU_macro_name, &ModuleInfo, &header);
   _pdm_status("GetMacroHeaderGivenName", status);

   if (status == 0)
     return(PDM_E_FAILURE);

  status = PDUis_macro_edited(&header);
  _pdm_status("PDUis_macro_edited", status);

  if (status == 0)
  {
  status = PDUedit_macro(&header, PDU_macro_dyn_list, PDU_macro_dyn_num);
  _pdm_status("PDUedit_macro", status);

  if (status == 0)
    return(PDM_E_FAILURE);

       status = ac$construct_wd ( mode = AC_SET,
                        name = PDU_macro_library,
                        dir  = &header );

   _pdm_status("ac$construct_wd", status);

  ac$save_wd();
  }

  status = PDM_S_SUCCESS;
  if (PDU_checkin_lib)
  {
  PDUfill_in_string(&refresh->rev_catalog, PDU_macro_catalog);
  PDUfill_in_string(&refresh->rev_partid, PDU_macro_partid);
  PDUfill_in_string(&refresh->rev_revision, PDU_macro_partrev);
  refresh->command = PDC_M_CHECKIN;
  PDUmessage_trans(PDC_M_CHECKIN, 'v');
  status = PDUexternal();
  _pdm_status("PDUexternal", status);
  PDUmessage_trans(status, 's');
  PDUfill_in_string(&refresh->rev_catalog, NULL);
  PDUfill_in_string(&refresh->rev_partid, NULL);
  PDUfill_in_string(&refresh->rev_revision, NULL);
  }
  return(status);
  }
  
IGRint PDUcvt_macro_library(macro_name)

IGRchar* macro_name;
  {
  IGRint status;
  long msg,NumberOfBytes,BytesReceived;
  struct GRid header;

  _pdm_debug("In PDUcvt_macro_library", 0);

   /* call function to edit macro header */
  NumberOfBytes = sizeof(ModuleInfo);
  gr$get_module_env( msg = &msg,
		     sizbuf = &NumberOfBytes,
		     buffer = &ModuleInfo,
		     nret = &BytesReceived);
  _pdm_status ("gr$get_module_env", msg);

   _pdm_debug("macro name = <%s>", macro_name);
  printf("GetMacroHeaderGivenName \n");
   status = GetMacroHeaderGivenName(macro_name, &ModuleInfo, &header);
   _pdm_status("GetMacroHeaderGivenName", status);

   if (status == 0)
     return(PDM_E_FAILURE);

  printf("PDUis_macro_edited \n");
  status = PDUis_macro_edited(&header);
  _pdm_status("PDUis_macro_edited", status);

  if (status == 0)
  {
  printf("PDUedit_macro \n");
  status = PDUedit_macro(&header);
  _pdm_status("PDUedit_macro", status);

  if (status == 0)
    return(PDM_E_FAILURE);

  printf("ac$save_wd \n");
  status = ac$save_wd();
  _pdm_status("ac$save_wd", status);
  }

  status = PDM_S_SUCCESS;
  return(status);
  }
  
IGRint PDUattach_macro_library(catalog, part, rev, part_cat, macro_lib)

IGRchar *catalog;
IGRchar *part;
IGRchar *rev;
IGRchar *part_cat;
IGRchar **macro_lib;

  {
  IGRint status;
  IGRint i;
  IGRint file_col;
  IGRint type_col;
  IGRchar **data_row = NULL;
  MEMptr file_bufr = NULL;
  struct  GRmd_env        mod_env;
  struct  PDUcat_node     *param_cat_list = NULL;
  struct  PDUcat_node     *head = NULL;
  struct  PDUcat_node     *tmp = NULL;
  struct  PDUattach_mac_node *temp = NULL;
  struct  PDUattach_mac_node *tail = NULL;
  extern short PDU_checkin_lib;
  extern struct PDUattach_mac_node *PDU_attach_macro_lib;

  _pdm_debug("In the PDUattach_macro_library", 0);

  /* Get module info */
  get_mod_info( &mod_env );
  
  /* Record attachment activity for later detachment, if necessary */
  status = PDUprepare_param_cats_list(
                                      &mod_env,
                                      &param_cat_list
                                     );
  _pdm_status("PDUprepare_param_cats_list", status);

  if (status != PDM_S_SUCCESS)
     {
      _pdm_debug("PDUprepare_param_cats_list failed", 0);
      return(status);
     }

  /* Delete placed part's catalog from param_cat_list */
  head = param_cat_list;

  if (head)
     tmp = head->next;

  while (head)
        {
         if (strcmp(param_cat_list->catalog, part_cat) == 0)
            {
             /* Delete node */
             if (param_cat_list->next == NULL)
                {
                 free(param_cat_list);
                 param_cat_list = NULL;
                }

             else
                 {
                  tmp = param_cat_list;
                  param_cat_list = param_cat_list->next;
                  free(tmp);
                 }

             break;
            }

         else
             {
              if (tmp)
                 {
                  if (strcmp(tmp->catalog, part_cat) == 0)
                     {
                      /* Delete node */
                      head->next = tmp->next;
                      free(tmp);
 
                      break;
                     }
                 }

               else
                   break;
              }

         /* Process next node */
         head = head->next;
         tmp = tmp->next;
        } /* end while loop */

  /* Add attach info to PDU_attach_macro_lib */
  temp = (struct PDUattach_mac_node *)malloc(sizeof(struct PDUattach_mac_node));

  /* Initialize temp fields */
  temp->part_cat = NULL;
  temp->cat_list = NULL;
  temp->next = NULL;

  PDUfill_in_string(&(temp->part_cat), part_cat);
  printf("5/n");

  if (param_cat_list)
     {
      temp->cat_list = param_cat_list;
     }

  /* Add file node to the end of PDU_attach_macro_lib list */
  if (PDU_attach_macro_lib)
     {
      /* Get to the end of list */
      tail = PDU_attach_macro_lib;
      while (tail->next)
            {
             tail = tail->next;
            }

      /* Add part to file link list */
      tail->next = temp;
     }

  else
      {
       /* This is the first node in the list */
       PDU_attach_macro_lib = temp;
      }
  
  status = PDMget_filenames(catalog, part, rev, &file_bufr);
  _pdm_status("PDMget_filenames", status);
  if (( status != PDM_S_SUCCESS ) || (file_bufr == NULL))
    return(status);
  else if (file_bufr->rows == 0)
    return(PDM_I_NO_FILES_FOUND);

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
  PDUget_buffer_col(file_bufr, "n_filetype", &type_col);
  _pdm_debug("rows = <%d>", file_bufr->rows);
  if (file_bufr->rows == 1) 
    PDUfill_in_string(macro_lib, data_row[file_col]);
  else if (file_bufr->rows == 0)
    return(PDM_I_NO_FILES_FOUND);
  else
    {
    for (i = 0; i < file_bufr->rows; i++)
     if (strcmp(data_row[(file_bufr->columns * i) + type_col], "M") == 0)
      {
      _pdm_debug("file type of M found", 0);
      PDUfill_in_string(macro_lib, data_row[(file_bufr->columns * i) + 
                        file_col]);
      break;
      }
    }
    
  if (*macro_lib == NULL) 
    return(PDM_I_NO_FILES_FOUND);
  else if (strcmp(*macro_lib, "") == 0)
    return(PDM_I_NO_FILES_FOUND);
  
   status = PDUverify_file(*macro_lib);
   _pdm_status("PDUverify_file", status);

  if (status != PDM_S_SUCCESS)
    return(status);

  /* attach macro library */
  status = ac$construct_path(mode = AC_ADD_PATH, 
                             name =  *macro_lib);
  _pdm_status("ac$construct_path", status);

  return(PDM_S_SUCCESS); 
  }

int PDUvalidate_expression(text)

IGRchar *text;

  {
  IGRint status;
  struct data_struct ret_val;
  IGRchar **arg_list = NULL;
  IGRchar type_obtained;
  IGRint  arg_num;
  
  _pdm_debug("IN PDUvalidate_expression", 0);

  status = new_exp_Parse(text,&ret_val,&arg_list,&arg_num,0,&type_obtained);
  _pdm_status("new_exp_Parse", status);

  if (!(status&1))
    return(PDM_E_FAILURE);

  return(PDM_S_SUCCESS);
  }

IGRint PDUrun_ppl(filename)

IGRchar *filename;
  {

   IGRint sts;
   IGRint response;
   GRobjid ppl_objid1;


   _pdm_debug("filename = <%s>", filename);
   sts = ci$load(file_name = filename,
                file_id         = &ppl_objid1,
                sender_id       = NULL_OBJID);

   if( ppl_objid1 == NULL_OBJID )
     {
     _pdm_debug("ci$load FAILED", 0);
      return(0);
     }


   sts = ci$run(file_id = &ppl_objid1,
                sender_id=NULL_OBJID,
                retval = &response );

   return(PDM_S_SUCCESS);
  }

IGRint PDUis_macro_library(filename)

IGRchar *filename;
  {

   IGRint status,sts;
   IGRint index;
   IGRint name_len = 0;
   IGRint msg;
   IGRchar mount_name[40];
   IGRchar name[40];
   GRobjid osid = NULL_OBJID;
   OMuword osnum;
   GRobjid objid;


   _pdm_debug("PDUis_macro_library", 0);
  /* Construct file mount name */
  strcpy(mount_name, ":");
  strcat(mount_name, filename);

  /* Get osnum of invis space */
  status = ex$retrieve_module (
                               filename = filename,
                               file_no = &index,
                               ftype = EX_invisible,
                               flag = EX_read_only,
                               fstat = EX_default,
                               type = EX_ACTINV,
                               mount_name = mount_name,
                               msg = &msg
                              );
 _pdm_status ("ex$retrieve_module", status);

 status = ex$get_invis_info_by_index (
                                      index = index,
                                      mod_osnum = &osnum,
                                      mod_id = &objid,
                                      filed_id = &osid
                                     );
 _pdm_status ("ex$get_invis_info_by_index", status);

status = ac$lib_name( osnum = osnum, name_size = 40, name = name, 
                      name_len = &name_len);
_pdm_status("ac$lib_name", status);
_pdm_debug("name_len = <%d>", name_len);
if (name_len > 1)
  status = 1;
else
  status = 0;

 /* Close and save object space */
 sts = ex$close_module (
                           index = index,
                           flag = 0 | EX_ACTINV,
                           ftype = EX_invisible
                          );
 _pdm_status ("ex$close_module", sts);

  return(status);
  }

IGRint PDUis_cell_library(filename)

IGRchar *filename;
  {

   IGRint status,sts;
   IGRint index;
   IGRint msg;
   IGRint file_open;
   IGRchar mount_name[40];
   IGRchar app[20];
   GRobjid osid = NULL_OBJID;
   OMuword osnum;
   GRobjid objid;


   _pdm_debug("PDUis_cell_library", 0);
  /* Construct file mount name */
  strcpy(mount_name, ":");
  strcat(mount_name, filename);

  /* Get osnum of invis space */
  file_open = ex$is_file_open(name = filename);
  _pdm_status("ex$is_file_open", file_open);

  if (file_open)
    return(0);
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
   _pdm_debug("retrieve_module", 0);
   return(0);
   }

 status = ex$get_invis_info_by_index (
                                      index = index,
                                      mod_osnum = &osnum,
                                      mod_id = &objid,
                                      filed_id = &osid
                                     );
 _pdm_status ("ex$get_invis_info_by_index", status);

    status =
    om$send(mode = OM_e_wrt_object,
            msg = message module.mod_info(EX_INQ, NULL, NULL, app, 20),
            senderid = NULL_OBJID,
            targetid = objid,
            targetos = osnum);
    _pdm_debug("app = <%s>", app);
    if (status &1)
    {
        if (! strcmp(app, "cell"))
        {
        status = 1;
        }
        else
        status = 0;
    }
    else
      status = 0;

 /* Close and save object space */
 sts = ex$close_module (
                           index = index,
                           flag = 1 | EX_ACTINV,
                           ftype = EX_invisible
                          );
 _pdm_status ("ex$close_module", sts);
 
  return(status);
  }

IGRint PDUis_grraster()

  {

   IGRint status,sts;
   IGRint response;
   static IGRint flag = FALSE;
   IGRchar path[80];
   GRobjid ppl_objid;

  _pdm_debug("Entering PDUis_grraster", 0);
   status = PDUget_grnuc_path(path);
   _pdm_status("PDUget_grnuc_path", status);

   _pdm_debug("path = <%s>", path);

   strcat(path, "config/dload/raster");
   status = PDUverify_file(path);
   _pdm_status("PDUverify_file", status);

   if (status != PDM_S_SUCCESS)
     {
     _pdm_debug("grraster is not loaded", 0);
     PDUmessage(PDM_I_GRRASTER_NOT_LOADED, 's');
     return(PDM_I_GRRASTER_NOT_LOADED);
     }

   strcpy(path, "");
   status = PDUget_grnuc_path(path);
   _pdm_status("PDUget_grnuc_path", status);

   _pdm_debug("path = <%s>", path);
   strcat(path, "ppl/bin/grraster.e");
   status = PDUverify_file(path);
   _pdm_status("PDUverify_file", status);

   if (status != PDM_S_SUCCESS)
     {
     _pdm_debug("grraster is not loaded", 0);
     PDUmessage(PDM_I_GRRASTER_NOT_LOADED, 's');
     return(PDM_I_GRRASTER_NOT_LOADED);
     }

   *((IGRchar *)strrchr(path, '.')) = '\0';
   if (!flag)
     {
     sts = ci$load(file_name = "grraster",
                file_id         = &ppl_objid,
                sender_id       = NULL_OBJID);

     if( ppl_objid == NULL_OBJID )
     {
     _pdm_debug("ci$load FAILED", 0);
      return(0);
     }


     sts = ci$run(file_id = &ppl_objid,
                sender_id=NULL_OBJID,
                retval = &response );
     flag = TRUE;
     status = PDM_S_SUCCESS;
     }
   status = PDM_S_SUCCESS;

  _pdm_debug("Leaving PDUis_grraster", 0);
  return(status);
  }

IGRint PDUexecute_ppl(filename, argument)

IGRchar *filename;
IGRchar *argument;
  {

   IGRint sts;
   IGRint response;
   IGRint length;
   IGRint resp;
   IGRint pos;
   IGRchar *file = NULL;
   IGRchar path[80];
   GRobjid ppl_objid1;

   sts = PDUget_pdu_path(path);
   _pdm_debug("PDU path = <%s>", path);

   length = strlen(filename) + strlen(path) + 10;
   file = (char *)malloc(length);
   memset(file, NULL, length);
   strcpy(file, path);
   strcat(file, "ppl/bin/");
   strcat(file, filename);

   _pdm_debug("ppl file path = <%s>", file);

   if (argument && (strlen(argument)))
     PDUfill_in_string(&PDU_save_filename, argument);
/*
     {
     resp = DATA;
     pos = FRONT;
     PDUput_queue(3, NULL, NULL, argument, NULL, &resp, NULL, NULL, NULL, &pos);
     _pdm_debug("after put_queue; exiting PDUexecute_grnuc_ppl", 0);
     }
*/

   sts = ci$load(file_name = file,
                file_id         = &ppl_objid1,
                sender_id       = NULL_OBJID);

   if( ppl_objid1 == NULL_OBJID )
     {
     _pdm_debug("ci$load FAILED", 0);
      return(0);
     }

   sts = ci$run(file_id = &ppl_objid1,
                sender_id=NULL_OBJID,
                retval = &response );

/*
   if (argument && (strlen(argument)))
     sts = ci$put(string = tmpfile);
*/

   _pdm_debug("exiting PDUexecute_ppl", 0);
   return(PDM_S_SUCCESS);
  }

int PDUupdate_ref_files_for_rev_assy(old_master_file, 
                                     new_master_file,
                                     old_file_list,
                                     new_file_list,
                                     file_count)
IGRchar    *old_master_file;
IGRchar    *new_master_file;
IGRchar    old_file_list[10][15];
IGRchar    new_file_list[10][15];
IGRint     file_count;
{

  IGRlong      status = PDM_S_SUCCESS;
  IGRlong      msg;
  IGRlong      NumberOfBytes, BytesReceived;
  IGRint       i = 0;
  IGRint       j = 0;
  IGRint       index = 0;
  IGRint       count = 0;
  IGRint       file_type;
  IGRint       msg2;
  IGRint       entry_count = 0;
  IGRchar      ref_dir[DI_PATH_MAX];
  IGRchar      save_dir[DI_PATH_MAX];
  IGRchar      child_dir[DI_PATH_MAX];
  IGRchar      ref_file[DI_PATH_MAX];
  IGRchar      **entries;
  IGRchar      mount_name[40];
  IGRchar      file_string[1024];
  IGRchar      dros_path[156];
  IGRchar      *tmpdir = NULL;
  IGRchar      *tmpfile = NULL;
  IGRchar      *old_ref = NULL;
  IGRchar      *new_ref = NULL;
  IGRchar      *cwd = NULL;
  IGRchar      mach_type;
  IGRshort     major;
  IGRshort     minor;
  IGRshort     found = FALSE;
  IGRshort     filename_generated = FALSE;
  OM_S_OBJID   osid = NULL_OBJID;
  OMuword      osnum;
  GRobjid      objid;
  struct       GRmd_env  mod_env;
  FILE         *outfile, *fopen ();
  register int ret_status;

  _pdm_debug("In the function PDUupdate_ref_files_for_rev_assy", 0);

  _pdm_debug("file is <%s>", new_master_file);

  status = ex$is_om_file(
                         filename = new_master_file,
                         p_major = &major,
                         p_minor = &minor,
                         p_mach_type = &mach_type,
                         p_file_type = &file_type
                        );
  _pdm_status("ex$is_om_file", status);

  if (status)
    {
    _pdm_debug("file <%s> is an OM file", new_master_file);
    }
  else
    {
    _pdm_debug("file <%s> is NOT an OM file", new_master_file);
    return(PDM_S_SUCCESS);
    }

  _pdm_debug("open OS for design file <%s>", new_master_file);
  _pdm_debug("Construct file mount name", 0);
  strcpy(mount_name, ":");
  strcat(mount_name, new_master_file);

  _pdm_debug("mount_name = <%s>", mount_name);

  _pdm_debug("Get osnum of invis space", 0);
  status = ex$retrieve_module (
                               filename = new_master_file,
                               file_no = &index,
                               ftype = EX_invisible,
                               flag = EX_read_write,
                               fstat = EX_default,
                               type = EX_ACTINV,
                               mount_name = mount_name,
                               msg = &msg2
                              );
  _pdm_status ("ex$retrieve_module", status);

  if (!status)
     {
      _pdm_debug("ex$retrieve_module failed on <%s>", new_master_file);
      return(PDM_E_OPEN_FILE);
     }

  _pdm_debug("opening object space", 0);
  status = ex$get_invis_info_by_index (
                                       index = index,
                                       mod_osnum = &osnum,
                                       mod_id = &objid,
                                       filed_id = &osid
                                      );
  _pdm_status ("ex$get_invis_info_by_index", status);

  if (!status)
     {
      _pdm_debug("ex$get_invis_info_by_index failed on <%s>", new_master_file);
      return(PDM_E_OPEN_FILE);
     }

  NumberOfBytes = sizeof(mod_env);
  status = gr$get_module_env(
                          msg = &msg,
                          sizbuf = &NumberOfBytes,
                          buffer = &mod_env,
                          nret = &BytesReceived
                        );

  mod_env.md_id.osnum = osnum;
  mod_env.md_id.objid = objid;

  /* Check to see if "ref" directory exists */
  di$give_pathname(
                   osnum = osnum,
                   pathname = ref_dir
                  );

  _pdm_debug("save path name for later", 0);
  strcpy(save_dir, ref_dir);

  _pdm_debug("ref_dir = <%s>", ref_dir);
  strcat(ref_dir,":ref:refnames");
  _pdm_debug("ref_dir = <%s>", ref_dir);

  status = di$find(
                   start_dir = ref_dir,
                   regexp = "*",
                   lines = &entries,
                   ptr = &entry_count,
                   max_level = 1
                  );

  _pdm_debug("entry_count = <%d>", entry_count);

  if ( (status != DIR_S_SUCCESS) || (entry_count <= 0) )
      {
      _pdm_debug("no ref directory found; return SUCCESS", 0);
      return(PDM_S_SUCCESS);
      }

  for (i = 0; i < entry_count; ++i)
     {
     _pdm_debug("entry = <%s>", entries[i]);
     found = FALSE;

     _pdm_debug("find the filename for each entry", 0);
     status = gr$get_ref_parameters(msg = &msg,
					ref_name = entries[i],
					mod_env = &mod_env,
					filename = ref_file);
     _pdm_status("gr$get_ref_parameters", status);
     _pdm_debug("ref_file = <%s>", ref_file);

     _pdm_debug("make sure the file is not already in the list", 0);
     for (j = 0; j < entry_count; ++j)
        {
        if (strcmp(entries[j], ref_file) == 0)
          {
          found = TRUE;
          break;
          }
        }

     if (!found)
       {
       _pdm_debug("change the attachment name to the ref_file name", 0);
       PDUfill_in_string(&entries[i], ref_file);
       }
     else
       {
       _pdm_debug("file <%s> was already in list; resetting entry", ref_file);
       PDUfill_in_string(&entries[i], "");
       }
     }

  _pdm_debug("new reffile list", 0);
  for (i = 0; i < entry_count; ++i)
     _pdm_debug("entry = <%s>", entries[i]);

/* 1/29/95 MJG - This is necessary so that I do not try to update the ref
   attachment for a part that was attached through PDU */
/*

  for (i = 0; i < entry_count; ++i)
     {
     if ((entries[i]) && (strlen(entries[i])))
       {
       _pdm_debug("check to see if file <%s> is a PDU design file", entries[i]);
       strcpy(child_dir, save_dir);
       strcat(child_dir, ":ref:");
       strcat(child_dir, entries[i]);
       strcat(child_dir, ":PDU_DESIGN_FILE");
       _pdm_debug("child_dir = <%s>", child_dir);

       status = di$ls(regexp = child_dir, ptr = &count);
       _pdm_debug("count = %d", (char *)count);
       if (count == 0)
         {
         _pdm_debug("file is not a PDU design file", 0);
         }
       else
         {
         _pdm_debug("file is a PDU design file; remove it from the list", 0);
         PDUfill_in_string(&entries[i], "");
         }
       }
    }
*/
     
  _pdm_debug("Close and do not save object space", 0);
  status = ex$close_module (
                            index = index,
                            flag = 0 | EX_ACTINV,
                            ftype = EX_invisible
                           );
  _pdm_status ("ex$close_module", status);
  status = PDM_S_SUCCESS;

/*  for each reference file, check to see if it is managed by PDM and update
    the attachment  */

  _pdm_debug("make sure the reference file is managed by PDM", 0);
  for (j = 0; j < entry_count; ++j)
     {
     found = FALSE;
     _pdm_debug("checking ref file <%s>", entries[j]);

     if (strcmp(entries[j], "") == 0)
       {
       _pdm_debug("skipping NULL entry", 0);
       continue;
       }

     for (i = 0; i < file_count; ++i)
        {
        if (strcmp(entries[j], old_file_list[i]) == 0)
          {
          _pdm_debug("matching entry found for <%s>", entries[0]);
          PDUfill_in_string(&old_ref, old_file_list[i]);
          PDUfill_in_string(&new_ref, new_file_list[i]);
          _pdm_debug("old_ref = <%s>", old_ref);
          _pdm_debug("new_ref = <%s>", new_ref);
          found = TRUE;
          }
        }

     if (!found)
       {
       _pdm_debug("reference file <%s> is not managed by PDM OR is not a multiple file", entries[j]);
       continue;
       }

     if (!filename_generated)
       {
       /* generate a unique filename */
/*
       tmpdir = ((char *)getenv ("TMPDIR"));
       if ((!tmpdir) || ((tmpdir) && (!strlen(tmpdir))))
         {
         _pdm_debug("defaulting tmpdir", 0);
         PDUfill_in_string(&tmpdir, "/usr/tmp");
         }
       _pdm_debug("tmpdir = <%s>", tmpdir);
*/
       tmpfile = tmpnam(NULL);
       if (!tmpfile)
         {
         _pdm_debug("error generating unique filename", 0);
         return(PDM_E_COPY_FILE);
         }
       _pdm_debug("tmpfile = <%s>", tmpfile);
/*
       strcpy(unique_file, tmpdir);
       strcat(unique_file, "/");
       strcat(unique_file, tmpfile);
       _pdm_debug("unique_file = <%s>", unique_file);
*/
       }

     /* construct string to be written to unique_file */
     strcpy(file_string, old_ref);
     strcat(file_string, " ");
     strcat(file_string, new_ref);
     strcat(file_string, " ");
     strcat(file_string, new_master_file);
    
     /* open the file and write the reference and master filenames */ 
     if ((outfile = fopen (tmpfile, "w")) == NULL)
       {
       _pdm_debug ("fopen: error opening <%s>", tmpfile);
       _pdm_debug ("fopen: errno = <%d>", (char *)errno);
       return (PDM_E_OPEN_FILE);
       }

     fprintf (outfile, "%s\n", file_string);
     fclose(outfile);

     status = PDUexecute_ppl("PDUUpdRefAtt", tmpfile);
     _pdm_status("PDUexecute_ppl", status);

     _pdm_debug("removing <%s>", tmpfile);
     unlink(tmpfile);

     /* create a file to run DROS on the new master file : this is necessary
        in order to restore associativity */
     _pdm_debug("preparing to run EXNUC DROS", 0);

     PDUfill_in_string(&cwd, user->wrkst_cwd);
     _pdm_debug("cwd = <%s>", cwd);

     _pdm_debug("Getting path of EXNUC", 0);
     status = PDUget_exnuc_path(dros_path);
     _pdm_status("PDUget_exnuc_path returns", status);

     if (status != PDM_S_SUCCESS)
       {
       _pdm_debug("failed to get EXNUC path", 0);
       return(status);
       }

     strcat(dros_path, "bin/dros");
     _pdm_debug("DROS Path is <%s>", dros_path);

     _pdm_debug("constructing string for DROS command line", 0);
     strcpy(file_string, dros_path);
     strcat(file_string, " -f ");
     strcat(file_string, new_master_file);
     strcat(file_string, " -R `");
     strcat(file_string, dros_path);
     strcat(file_string, " -f ");
     strcat(file_string, old_ref);
     strcat(file_string, " -N` `");
     strcat(file_string, dros_path);
     strcat(file_string, " -f ");
     strcat(file_string, new_ref);
     strcat(file_string, " -N`");

     _pdm_debug("file_string = <%s>", file_string);
		
     _pdm_debug("calling system", 0);
     ret_status = system(file_string);
     if (ret_status == -1)
       {
       _pdm_debug("system failed with errno %d", (char *)errno);
       return(PDM_E_COPY_FILE);
       }
     else
       _pdm_debug("dros successful", 0);

     }

  return(status);
}

end implementation COpdu;
