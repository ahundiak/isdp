#include	<stdio.h>
#include	<PDUstr.h>
#include	<PDUuser.h>
#include	<PDUerror.h>
#include        <PDUcommand.h>
#include        <PDUforms.h>
#include        <PDUfile_def.h>
#include        <PDUstorage.h>
#include        <MEMerrordef.h>
#include        <MEMstruct.h>
#include	<errno.h>
#include	<sys/types.h>
#include	<sys/stat.h>
#include        "PDUproto.h"
#include        "PDMproto.h"

#define LIST_MCF      11
#define DELETE_LOCAL_BTN 36
#define SIMILAR_MODE_MCF 36

extern struct PDUforms  forms;
extern MEMptr PDU_parts_list_bufr;
extern MEMptr PDU_storage_area;
extern int    PDU_selected_rows;
extern int    PDU_mcf_list;
extern int    PDU_simmode_copy;
extern int    PDMdebug_on;
extern int    *PDU_parts_index;
extern Form   PDU_form_id;
extern  struct  PDUstorage *storage;
extern struct PDUrefresh  *refresh;
extern char **PDU_file_list;

int PDUdelete_local_files(file_bufr, command, type)
  MEMptr        file_bufr;
  int           command;
  int           type;
  {
  int           status = PDM_S_SUCCESS;
  int           row = 0;
  MEMptr	return_buffer = NULL;

  _pdm_debug("in the function PDUdelete_local_files", 0);

  if (PDMdebug_on)
    MEMprint_buffer("delete local files file_bufr", file_bufr, PDU_DEBUG_FILE);

  status = PDMrdelete_local_files(file_bufr, &return_buffer);
  _pdm_status("PDMrdelete_local_files", status);

  if ((status != PDM_S_SUCCESS) && (PDU_form_id == forms.local_files_form_id) &&
      (PDU_mcf_list == TRUE))
    {
    /* reset the part listing area on the form */
    for (row = row; row < PDU_parts_list_bufr->rows; ++row)
       FImcf_set_select(forms.local_files_form_id, LIST_MCF, row, FALSE);

    /* reset the integer array that points to the rows */
    PDU_parts_index = (int *) malloc (sizeof (int) * PDU_parts_list_bufr->rows);
    memset(PDU_parts_index, -1, sizeof (int) * PDU_parts_list_bufr->rows);
    PDU_selected_rows = 0;

    PDUmessage(status);
    FIg_disable(PDU_form_id, DELETE_LOCAL_BTN);
    return(status);
    }

  _pdm_debug("status = %d", (char *)status);
  _pdm_debug("PDU_mcf_list = %d", (char *)PDU_mcf_list);
  if ((status == PDM_S_SUCCESS) && (PDU_form_id == forms.local_files_form_id) &&
      (PDU_mcf_list == TRUE))
    {
    /* call function to update the file local column on the form */
    if (type == REFRESH_PART)
      {
/* 2/7/96 MJG - TR 139526084 */
/* Added argument to function call.  The parts in file_bufr will be compared
   to those in return_bufr to determine which parts are attachments */

      status = PDUupdate_local_column_for_refresh(command, return_buffer, NULL);
      _pdm_status("PDUupdate_local_column_for_refresh", status);
      }
    else if (type == LIST_PART)
      {
      status = PDUupdate_local_column(command, return_buffer, NULL);
      _pdm_status("PDUupdate_local_column", status);
      }
    }

  FIg_disable(PDU_form_id, DELETE_LOCAL_BTN);
  PDUmessage(status, 's');
  return(status);
  }

int  PDUext_cancel_checkout()
  {
     int        sts = PDM_S_SUCCESS;
     long       status = PDM_S_SUCCESS;
     char       dir_entry_name[1024];
     char       *status_msg;
     char       **file_name_list;
     int        row_count = 0, i;
     MEMptr     attach_bufr = NULL;
     struct stat file_status;
     struct PDUcat_node *param_cat_list = NULL;
     extern struct PDUuser     *user;

     _pdm_debug("In the function PDUext_cancel_checkout",0);

     status = PDMvalidate_user_access("PDMCancel Part Check Out", NULLSTR,
               refresh->rev_catalog, NULLSTR, refresh->rev_partid,
               refresh->rev_revision );
     _pdm_status ("PDMvalidate_user_access", status);

     _pdm_debug("Default case ", 0);

     if (status != PDM_S_SUCCESS)
       {
       PDUmessage(status, 's');
       return(status);
       }

     /* JAMAL- attach buffer is needed for cancel checkout */
     status = PDUget_child_attach_bufrs(
                                        refresh->rev_catalog,
                                        refresh->rev_partid,
                                        refresh->rev_revision,
                                        &attach_bufr,
                                        &param_cat_list
                                       );
     _pdm_status("PDUget_child_attach_bufrs", status);

     if (status != PDM_S_SUCCESS)
        {
         if (status != PDM_E_OPEN_FILE_NOT_ALLOWED)
            status = PDM_E_GET_ATTACH_INFO;

         PDUmessage(status, 's');
         _pdm_debug("PDUget_child_attach_bufr failed", 0);
         return(status);
        }

     /* get list of file names to be deleted */
         status = PDMrcancel_checkout_part(
                                           refresh->rev_catalog,
                                           refresh->rev_partid,
                                           refresh->rev_revision,
                                           attach_bufr,
                                           param_cat_list,
                                           &file_name_list,
                                           &row_count
                                          );
         _pdm_status("PDMrcancel_checkout_part",status);

         if ((status == PDM_S_SUCCESS) && (row_count))
            {
             _pdm_debug("rows found = <%d>",(char *)row_count);

             for (i = 0; i < row_count; ++i)
                 {
                  /* make sure file exists */
                  strcpy(dir_entry_name,user->wrkst_cwd);
                  strcat(dir_entry_name,"/");

                  strcat(dir_entry_name,file_name_list[i]);
                  _pdm_debug("full entry path name = <%s>",dir_entry_name);

                  status = stat(dir_entry_name,&file_status);
                  if (status == 0) /* entry exists */
                     {
                      /* delete file locally */
                      _pdm_debug("entry was found",0);
                      status = unlink(dir_entry_name);
                      if (status == 0)
                         {
                          _pdm_debug("entry <%s> was removed successfully",
                                     dir_entry_name);
                         }
                      else
                         {
                          _pdm_debug("entry <%s> removal failed",
                                     dir_entry_name);
                         }
                     }
                  else
                      _pdm_debug("entry <%s> was not found locally",
                                 dir_entry_name);
                 } /* end for loop */

              status = PDM_S_SUCCESS;
            }
        else
            if (status != PDM_S_SUCCESS)
               {
                PDUmessage(status, 's');
                _pdm_debug("PDMrcancel_checkout_part failed",0);
                return(status);
               }

     PDUmessage(status, 's');

/* VASU - 17.02.92 - Added a type cast to (char *)
     status_msg = PDUtranslate_message(status);
*/
     status_msg = (char *) PDUtranslate_message(status);  /* VASU - 17.02.92 */

     _pdm_debug("Error string = <%s>", status_msg);

     sts = PDMset_to_state ( status, "PDM", status_msg );
     _pdm_status ("PDMset_to_state", sts);

     /* reset the file local and workflow state columns */
     if ((PDU_mcf_list == TRUE) && (status == PDM_S_SUCCESS))
       PDUupdate_form_after_checkin_out(CANCEL_CHECKOUT);

     return(status);
  }

int PDUcancel_checkout()
{
char    *command_string = NULL;
int     command_type;
int     status = PDM_S_SUCCESS;

  PDUfill_in_string(&command_string, "cancel checkout");
  command_type = CANCEL_CHECKOUT;

  status = PDUcheck_part(command_string, command_type);
  _pdm_status("PDUcheck_part", status);

  return(status);
}  /* end PDUcancel_checkout */

int PDUdelete_file()
{
char    *command_string = NULL;
int     command_type;
int     status = PDM_S_SUCCESS;

  PDUfill_in_string(&command_string, "delete local");
  command_type = DELETE_LOCAL;

  status = PDUcheck_part(command_string, command_type);
  _pdm_status("PDUcheck_part", status);

  return(status);
}  /* end PDUdelete_file */

int PDUremove_files_locally(file_buffer)

 MEMptr  file_buffer;
{
 long    status = PDM_S_SUCCESS;
 int     i;
 int     file_col;
 char    full_name[256];
 char    **file_names;
 char    local_files_path[256];
 struct  stat file_status;
 extern  struct PDUuser  *user;

 _pdm_debug("In the PDUremove_files_locally function", 0);

 /* Check to see if file buffer is empty */
 if ( !(file_buffer) || (file_buffer->rows <= 0) )
    {
     _pdm_debug("no files to remove locally", 0);
     return(PDM_S_SUCCESS);
    }

 MEMbuild_array(file_buffer);

 status = PDUget_buffer_col(
                   	    file_buffer,
                   	    "n_cofilename",
                   	    &file_col
                  	   );
 if (status != PDM_S_SUCCESS)
    return(status);


 file_names = (char **) file_buffer->data_ptr;

 /* Construct local files full path */
 strcpy(local_files_path, user->wrkst_cwd);
 strcat(local_files_path, "/");
 _pdm_debug("local files full path = <%s>", local_files_path);

 /* Loop thru file buffer deleting files */
 for (i = 0; i < file_buffer->rows; ++i)
     {
      strcpy(full_name, local_files_path);
      strcat(full_name, file_names[i]);

      _pdm_debug("removing <%s> locally", full_name);

      status = stat(full_name, &file_status);
      if (status == 0)
         {
          /* Remove file */
          unlink(full_name);

          if (status == 0)
             {
              _pdm_debug("file <%s> was deleted successfully", full_name);
             }

           else
               {
                _pdm_debug("failed to delete file <%s>", full_name);
               }
         }

      else
         {
          _pdm_debug("file <%s> does not exist locally", full_name);
         }

     } /* end for loop */

 return(PDM_S_SUCCESS);
}


int PDUremove_local_files_after_delete(file_buffer)
  MEMptr  file_buffer;
{

  int	cat_col;
  int	part_col;
  int	rev_col;
  int	action_col;
  int	file_col;
  int	type_col;
  int   row;
  int   num_rows;
  int   index;
  int	status = PDM_S_SUCCESS;
  short found = FALSE;
  short attached = FALSE;
  FILE    *fopen ();
  struct  stat file_status;
  char    str1[200];
  char    *action = NULL;
  char    *filename = NULL;
  char    *parttype = NULL;
  char    **file_data;
  MEMptr  buffer = NULL;

  _pdm_debug("PDUremove_local_files_after_delete", 0);

  if ((file_buffer == NULL) || (file_buffer->rows == 0))
    {
    PDUmessage(PDM_E_DELETE_FILES, 's');
    return(PDM_E_DELETE_FILES);
    }

  MEMbuild_array(file_buffer);
  status = PDUget_buffer_col(file_buffer, "n_catalogname", &cat_col);
  if (status != PDM_S_SUCCESS)
     return(status);

  status = PDUget_buffer_col(file_buffer, "n_itemname", &part_col);
  if (status != PDM_S_SUCCESS)
     return(status);

  status = PDUget_buffer_col(file_buffer, "n_itemrev", &rev_col);
  if (status != PDM_S_SUCCESS)
     return(status);

  status = PDUget_buffer_col(file_buffer, "p_action", &action_col);
  if (status != PDM_S_SUCCESS)
     return(status);

  status = PDUget_buffer_col(file_buffer, "n_cofilename", &file_col);
  if (status != PDM_S_SUCCESS)
     return(status);

  status = PDUget_buffer_col(file_buffer, "p_parttype", &type_col);
  if (status != PDM_S_SUCCESS)
     return(status);

  PDUsetup_buffer(file_buffer, ROW, &file_data);

  for (row = 0; row < file_buffer->rows; ++row)
     {
     found = FALSE;
     PDUfill_in_string(&filename, 
                       file_data[(file_buffer->columns * row) + file_col]);
     PDUfill_in_string(&action, 
                       file_data[(file_buffer->columns * row) + action_col]);
     _pdm_debug("filename = <%s>", filename);
     _pdm_debug("action = <%s>", action);

       /* get the parttype from the buffer */
       _pdm_debug("retrieving parttype", 0);
       PDUfill_in_string(&parttype,
                       file_data[(file_buffer->columns * row) + type_col]);
       _pdm_debug("parttype = <%s>", parttype);

       if ((strcmp(parttype, "M") == 0) && (strcmp(action, "SUCCESS") == 0))
         {
         _pdm_debug("deleting macro file", 0);
         sprintf(str1,"%s/%s",storage->path_name, filename);
         _pdm_debug("Full path name = <%s>", str1);

         status = unlink(str1);
         if (status == 0)
           _pdm_debug("macro file was removed successfully", 0);
         if (status != 0)
           _pdm_debug("macro file removal failed",0);

         /* check for unbundled cpio files */
         _pdm_debug("checking for unbundled cpio files", 0);
         sprintf(str1,"%s/%s%s",storage->path_name, ".", filename);
         _pdm_debug("Full path name = <%s>", str1);

         status = stat(str1,&file_status);
         if (status == 0) /* file exists */
           {
           status = PDUdelete_cpio_files(str1);
           _pdm_status("PDUdelete_macro_files", status);

           /* delete the cpio file locally */
           _pdm_debug("entry was found",0);
           status = unlink(str1);
           if (status == 0)
             _pdm_debug("cpio file was removed successfully", 0);
           if (status != 0)
             _pdm_debug("cpio file removal failed",0);
           }
         }

     if ((strcmp(action, "SUCCESS") == 0) && 
         (parttype) && (strcmp(parttype, "M") != 0))
       {
       _pdm_debug("file to delete is <%s", filename);
       if ((PDU_form_id == forms.part_operations_form_id) && (PDU_simmode_copy))
         {
         if (PDU_file_list)
           {
           _pdm_debug("checking for EMS ref file attachments", 0);
           FIfld_get_num_rows(PDU_form_id, SIMILAR_MODE_MCF, &num_rows);
           _pdm_debug("num_rows = %d", (char *)num_rows);
           for (index = 0; index < num_rows; ++index)
              {
               if (strcmp(PDU_file_list[index], filename) == 0)
                {
                _pdm_debug("not deleting file <%s>", PDU_file_list[index]);
                found = TRUE;
                break;
                }
              }
            }
/*
         if (!found)
           {
           _pdm_debug("checking for attachments", 0);
           status = PDUcheck_if_file_attached(filename, &attached, &buffer);
           _pdm_status("PDUcheck_if_file_attached", status);
           }
*/
         }
       if (found || attached)
         continue;

       _pdm_debug("deleting file locally", 0);
       sprintf(str1,"%s/%s",storage->path_name, filename);
       _pdm_debug("Full path name = <%s>", str1);
 
       /* make sure file exists */
       status = stat(str1,&file_status);
       if (status == 0) /* file exists */
         {
         /* delete file locally */
         _pdm_debug("entry was found",0);
         status = unlink(str1);
         if (status == 0)
           _pdm_debug("file was removed successfully", 0);
         if (status != 0)
           _pdm_debug("file removal failed",0);
         }
       else
          _pdm_debug("file was not found locally",0);
       }

     }

  return(PDM_S_SUCCESS);
}

int PDUdelete_cpio_files(path)
  char    *path;
{
  FILE    *infile, *fopen ();
  struct  stat buf;
  struct  stat file_status;
  char    str1[200];
  char    *filename = NULL;
  int     status = PDM_S_SUCCESS;
  int     status1 = PDM_S_SUCCESS;

  _pdm_debug("in the function PDUdelete_cpio_files", 0);

  /* open the macro file */
  if (stat (path, &buf))
    {
    _pdm_debug ("PDUdelete_macro_files: stat failed; errno = %d", 
               (char *)errno);
    _pdm_debug ("PDUdelete_macro_files: returning %d", (char *)PDM_E_OPEN_FILE);
    return (PDM_E_OPEN_FILE);
    }

  if (buf.st_size == 0)
    {
    _pdm_debug ("PDUdelete_macro_files: file is empty", 0);
    return(PDM_S_SUCCESS);
    }

  if ((infile = fopen (path, "r")) == NULL)
    {
    _pdm_debug ("PDUdelete_macro_files: error opening <%s>", path);
    _pdm_debug ("PDUdelete_macro_files: errno = <%d>", (char *)errno);
    return (PDM_E_OPEN_FILE);
    }

  while (status == PDM_S_SUCCESS)
    {
    status = PDUread_refresh_file(&filename, path, infile);
    _pdm_status("PDUread_refresh_file", status);

    if (status != PDM_S_SUCCESS)
      {
      fclose(infile);
      return(status);
      }

    /* delete the file locally */
    sprintf(str1,"%s/%s",storage->path_name, filename);
    _pdm_debug("Full path name = <%s>", str1);

    /* make sure file exists */
    status1 = stat(str1,&file_status);
    if (status1 == 0) /* file exists */
      {
      /* delete file locally */
      _pdm_debug("entry was found",0);
      status1 = unlink(str1);
      if (status1 == 0)
        _pdm_debug("file <%s> was removed successfully", filename);
      if (status1 != 0)
        _pdm_debug("file <%s> removal failed",filename);
      }
    
    }

  return(status);
}


int PDUchange_to_read_only(part_files)

 MEMptr  part_files;
{
 long    status = PDM_S_SUCCESS;
 int     i;
 int     file_col;
 char    full_name[256];
 char    **file_names;
 char    local_files_path[256];
 struct  stat file_status;
 mode_t  mode;
 extern  struct PDUuser  *user;

 _pdm_debug("In the PDUchange_to_read_only function", 0);

 /* Check to see if file buffer is empty */
 if ( !(part_files) || (part_files->rows <= 0) )
    {
     _pdm_debug("no files to change permissions on", 0);
     return(PDM_S_SUCCESS);
    }

 MEMbuild_array(part_files);

 status = PDUget_buffer_col(
                   	    part_files,
                   	    "n_cofilename",
                   	    &file_col
                  	   );
 if (status != PDM_S_SUCCESS)
    return(status);


 file_names = (char **) part_files->data_ptr;

 /* Construct local files full path */
 strcpy(local_files_path, user->wrkst_cwd);
 strcat(local_files_path, "/");

 _pdm_debug("local files full path = <%s>", local_files_path);

 /* Loop thru part files buffer changing permissions */
 for (i = 0; i < part_files->rows; ++i)
     {
      strcpy(full_name, local_files_path);
      strcat(full_name, file_names[i]);

      _pdm_debug("changing permissions on <%s>", full_name);

      status = stat(full_name, &file_status);
      if (status == 0)
         {
          /* Change file permissions to read only */
          mode = S_IRUSR | S_IRGRP | S_IROTH;
          status = PDUchmod(full_name, mode);

          if (status != PDM_S_SUCCESS)
             {
              _pdm_debug("PDUchmod failed", 0);
              return(status);
             }
         }

      else
         {
          _pdm_debug("file <%s> does not exist locally", full_name);
         }

     } /* end for loop */

 return (PDM_S_SUCCESS);
}

int PDUcopy_attach(p_seqno, catalog, part_num, revision, attach_type,
                        file_buffer)
long    p_seqno;
char    *catalog;
char    *part_num;
char    *revision;
int     attach_type;
MEMptr  *file_buffer;
{
 p_seqno = 0;
 catalog = "";
 part_num = "";
 revision = "";
 attach_type = 0;
 *file_buffer = NULL;
 return(1);
}

int PDUcheck_if_file_attached(filename, attached, ret_bufr)
char  *filename;
short   *attached;
MEMptr  *ret_bufr;
{
  int status = PDM_S_SUCCESS;
  int   row = 0;
  int   file_col = 0;
  char  **data_row;
  char  *file = NULL;
  short found = FALSE;

  _pdm_debug("in the function PDUcheck_if_file_attached", 0);

  if (!(*ret_bufr))
    {
    status = PDMget_filenames(refresh->rev_catalog,refresh->rev_partid,
                          refresh->rev_revision, ret_bufr);
    _pdm_status("PDMget_filenames", status);
     
    if ( status != PDM_S_SUCCESS )
      {
      MEMclose(ret_bufr);
      PDUmessage(PDM_E_NO_PART_FILES, 's');
      return(status);
      }
  
    if ((*ret_bufr == NULL) || ((*ret_bufr)->rows == 0))
      {
      PDUmessage(PDM_E_FILE_NOT_FOUND, 's');
      return(PDM_E_FILE_NOT_FOUND);
      }
    }

  MEMbuild_array(*ret_bufr);
  PDUsetup_buffer(*ret_bufr, ROW, &data_row);
  status = PDUget_buffer_col(*ret_bufr, "n_cofilename", &file_col);
  if (status != PDM_S_SUCCESS)
    return(status);

  _pdm_debug("initializing attached", 0);
  *attached = FALSE;

/*  Theory - You know the file is attached if it is not present in the list
    of filenames, but it does exist in the list of files to delete from
    delete local files.  mjg
*/
    
  for (row = 0; row < (*ret_bufr)->rows; ++row)
     {
     PDUfill_in_string(&file, data_row[((*ret_bufr)->columns * row)+file_col]);
     _pdm_debug("file = <%s>", file);
     if (strcmp(file, filename) == 0)
       {
       _pdm_debug("file <%s> is not an attachment", file);
       found = TRUE;
       break;
       }
     }

  if (!found)
    *attached = TRUE;

  return(status);
}

int PDUcopy_files_for_refresh_part()
{

  int status = PDM_S_SUCCESS;
  int sts = PDM_S_SUCCESS;
  MEMptr buffer = NULL;
  MEMptr return_buffer = NULL;
  char *status_msg = NULL;

  _pdm_debug("in the function PDUcopy_files_for_refresh_part", 0);

  status = PDUverify_file(refresh->rev_filename);
  _pdm_status("PDUverify_file",status);

  if (status == PDM_S_SUCCESS)
    {
    PDUmessage(PDM_E_FILE_LOCAL, 's');
    return(PDM_E_FILE_LOCAL);
    }

  status = PDUcreate_file_buffer_from_refresh(COPY_LOCAL, &buffer);
  _pdm_status("PDUcreate_file_buffer_from_refresh", status);

  if (status != PDM_S_SUCCESS)
    {
    PDUmessage(status, 's');
    return(status);
    }

  if ((buffer) && (buffer->rows == 0))
    {
    status = PDM_E_COPY_LIST_EMPTY;
    PDUmessage(status, 's');
    MEMclose(&buffer);
    return(status);
    }

  /* copy part graphics file to the workstation */
  status = PDMcopy(buffer, &return_buffer);
  _pdm_status ("PDMcopy (file)", status);

  status_msg = (char *) PDUtranslate_message(status);
  _pdm_debug("Error string = <%s>", status_msg);

  sts = PDMset_to_state ( status, "PDM", status_msg );
  _pdm_status ("PDMset_to_state", sts);

  _pdm_debug("checking to see if COPY was successful", 0);
  status = PDUverify_file(refresh->rev_filename);
  _pdm_status("PDUverify_file",status);

  if (status != PDM_S_SUCCESS)
    {
    PDUmessage(PDM_E_COPY_FILE, 's');
    return(PDM_E_COPY_FILE);
    }

  return(status);
}
