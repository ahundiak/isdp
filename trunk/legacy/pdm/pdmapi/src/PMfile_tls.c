#include "stdio.h"
#include "PDUfile_def.h"
#include "PDUerror.h"
#include "PDUintdef.h"
#include "PDUpart_str.h"
#include "MEMstruct.h"
#include "MEMerrordef.h"
#include "PDMproto.h"
#include "PDUproto.h"

extern int PDMdebug_on;
extern char PDU_DEBUG_FILE[80];

int PDUadd_files_to_buffer(file_bufr, add_list, saname)
MEMptr    *file_bufr;
struct file_info *add_list;
char      *saname;
{

  long    status = PDM_S_SUCCESS;
  int     cifile_col = 0;
  int     cofile_col = 0;
  int     row = 0;
  int     char_index = 0;
  int     col = 0;
  char    cifilename[15];
  char    cofilename[15];
  char    *line = NULL;
  char    **data_row;

  _pdm_debug("in the function PDUadd_files_to_buffer", 0);

  if (!*file_bufr)
    {
    /* create the file_bufr */
    status = PDUformat_buffer(PDU_ADD_FILE_BUFFER, file_bufr);
    _pdm_status("PDUformat_buffer", status);
  
    if (status != PDM_S_SUCCESS)
      return(status);
  
    line = (char*) malloc ((*file_bufr)->row_size);
    memset (line, NULL, (*file_bufr)->row_size);
    char_index = 0;
  
    /* write a blank first row to the file buffer */
    for (col = 0; col < (*file_bufr)->columns; ++col)
       line[col] = '\1';
  
    status = MEMwrite (*file_bufr, line);
    _pdm_status("MEMwrite", status);
     
    if (status != MEM_S_SUCCESS)
      {
      _pdm_debug("Error writing to file_bufr", 0);
      return(PDM_E_WRITE_BUFFER);
      }
    else 
      status = PDM_S_SUCCESS;
    }
  else
    line = (char*) malloc ((*file_bufr)->row_size);

  if (!add_list)
    return(PDM_E_NULL_FILE_LIST);

  if (PDMdebug_on)
  MEMprint_buffer("original file_bufr", *file_bufr, PDU_DEBUG_FILE);

  status = MEMbuild_array(*file_bufr);
  _pdm_status("MEMbuild_array", status);
  if (status != MEM_S_SUCCESS)
    return(PDM_E_BUILD_BUFFER_ARRAY);

  PDUsetup_buffer(*file_bufr, ROW, &data_row);

  status = PDUget_buffer_col(*file_bufr, "n_cifilename", &cifile_col);
  if (status != PDM_S_SUCCESS)
    return(status);

  status = PDUget_buffer_col(*file_bufr, "n_cofilename", &cofile_col);
  if (status != PDM_S_SUCCESS)
    return(status);

  cifilename[0] = '\0';
  cofilename[0] = '\0';

  /* add each node in the linklist to the file_bufr */
  while (add_list)
    {
    memset (line, NULL, (*file_bufr)->row_size);
    char_index = 0;

    /* search through the file_bufr for duplicate filenames */
    for (row = 1; row < (*file_bufr)->rows; ++row)
       {
       strcpy(&cifilename,data_row[((*file_bufr)->columns * row) + cifile_col]);
       strcpy(&cofilename,data_row[((*file_bufr)->columns * row) + cofile_col]);

       if (((strlen(add_list->cpr_local_fn) > 0) && 
            (strcmp(add_list->cpr_local_fn, cofilename) == 0)) ||
            (strlen(add_list->cpr_storage_fn) > 0) &&
            (strcmp(add_list->cpr_storage_fn, cifilename) == 0))
         {
         _pdm_debug("duplicate filename found in add_list", 0);
         return(PDM_E_DUPLICATE_FILENAME);
         }
       }

     line[char_index++] = '\1';  /* entry for n_filenum */

     if (add_list->cpr_local_fn && (strlen (add_list->cpr_local_fn )))
       PDUadd_buffer_string(line, &char_index, add_list->cpr_local_fn);
     else
       line[char_index++] = '\1';
 
     if (add_list->cpr_file_type && (strlen (add_list->cpr_file_type )))
       PDUadd_buffer_string(line, &char_index, add_list->cpr_file_type);
     else
       line[char_index++] = '\1';
 
     if (saname && (strlen (saname )))
       PDUadd_buffer_string(line, &char_index, saname);
     else
       line[char_index++] = '\1';
 
     if (add_list->cpr_storage_fn && (strlen (add_list->cpr_storage_fn )))
       PDUadd_buffer_string(line, &char_index, add_list->cpr_storage_fn);
     else
       line[char_index++] = '\1';
 
     line[char_index++] = '\1';  /* entry for n_cosano */
     line[char_index++] = '\1';  /* entry for n_couser */

     if (add_list->cpr_file_desc && (strlen (add_list->cpr_file_desc )))
       PDUadd_buffer_string(line, &char_index, add_list->cpr_file_desc);
     else
       line[char_index++] = '\1';

     _pdm_debug("line = <%s>", line);
     status = MEMwrite (*file_bufr, line);
     _pdm_status("MEMwrite", status);
 
     if (status != MEM_S_SUCCESS)
       {
       _pdm_debug("Error writing to file_bufr", 0);
       return(PDM_E_WRITE_BUFFER);
       }
     else 
       status = PDM_S_SUCCESS;

   add_list = add_list->spm_next;
   }

  if (PDMdebug_on)
  MEMprint_buffer("modified file_bufr", *file_bufr, PDU_DEBUG_FILE);

  free(line);

  return(status);
}

int PDUchange_files_in_buffer(file_bufr, chg_list)
MEMptr    *file_bufr;
struct chg_file_info *chg_list;
{

  long    status = PDM_S_SUCCESS;
  int     cifile_col = 0;
  int     cofile_col = 0;
  int     desc_col = 0;
  int     type_col = 0;
  int     status_col = 0;
  int     row = 0;
  int     char_index = 0;
  char    cifilename[15];
  char    cofilename[15];
  char    filedesc[256];
  char    filetype[6];
  char    *line = NULL;
  char    **data_row;

  _pdm_debug("in the function PDUchg_files_in_buffer", 0);

  if (!*file_bufr)
    return(PDM_E_NULL_BUFFER);

  if (!chg_list)
    return(PDM_E_NULL_FILE_LIST);

  if (PDMdebug_on)
  MEMprint_buffer("original file_bufr", *file_bufr, PDU_DEBUG_FILE);

  status = MEMbuild_array(*file_bufr);
  _pdm_status("MEMbuild_array", status);
  if (status != MEM_S_SUCCESS)
    return(PDM_E_BUILD_BUFFER_ARRAY);

  PDUsetup_buffer(*file_bufr, ROW, &data_row);

  status = PDUget_buffer_col(*file_bufr, "n_cifilename", &cifile_col);
  if (status != PDM_S_SUCCESS)
    return(status);

  status = PDUget_buffer_col(*file_bufr, "n_cofilename", &cofile_col);
  if (status != PDM_S_SUCCESS)
    return(status);

  status = PDUget_buffer_col(*file_bufr, "n_filetype", &type_col);
  if (status != PDM_S_SUCCESS)
    return(status);

  status = PDUget_buffer_col(*file_bufr, "p_filedesc", &desc_col);
  if (status != PDM_S_SUCCESS)
    return(status);

  status = PDUget_buffer_col(*file_bufr, "n_status", &status_col);
  if (status != PDM_S_SUCCESS)
    return(status);

  line = (char*) malloc ((*file_bufr)->row_size);

  cifilename[0] = '\0';
  cofilename[0] = '\0';

  /* change each node in the linklist to the file_bufr */
  while (chg_list)
    {
    _pdm_debug("row to match is:", 0);

    _pdm_debug("cpr_local_fn = <%s>", chg_list->cpr_local_fn);
    _pdm_debug("cpr_storage_fn = <%s>", chg_list->cpr_storage_fn);
    _pdm_debug("cpr_file_desc = <%s>", chg_list->cpr_file_desc);
    _pdm_debug("cpr_file_type = <%s>", chg_list->cpr_file_type);

    memset (line, NULL, (*file_bufr)->row_size);
    char_index = 0;

    /* search through the file_bufr for duplicate filenames */
    for (row = 1; row < (*file_bufr)->rows; ++row)
       {
       strcpy(cifilename, data_row[((*file_bufr)->columns * row) + cifile_col]);
       strcpy(cofilename, data_row[((*file_bufr)->columns * row) + cofile_col]);

       if ((strlen(chg_list->cpr_chg_local_fn)) && (strlen(cofilename)) &&
           (strcmp(chg_list->cpr_chg_local_fn, cofilename) == 0))
         {
         _pdm_debug("duplicate filename found in chg_list", 0);
         return(PDM_E_DUPLICATE_FILENAME);
         }

       if ((strlen(chg_list->cpr_chg_storage_fn)) && (strlen(cifilename)) &&
           (strcmp(chg_list->cpr_chg_storage_fn, cifilename) == 0))
         {
         _pdm_debug("duplicate filename found in chg_list", 0);
         return(PDM_E_DUPLICATE_FILENAME);
         }
       }

     /* find the matching row in the buffer */
     _pdm_debug("looking for matching row in buffer", 0);
     for (row = 0; row < (*file_bufr)->rows; ++row)
        {
        _pdm_debug("row = %d", (char *)row);
	cifilename[0] = '\0';
	cofilename[0] = '\0';
	filedesc[0] = '\0';
	filetype[0] = '\0';

        strcpy(&cifilename,data_row[((*file_bufr)->columns*row) + cifile_col]);
        strcpy(&cofilename,data_row[((*file_bufr)->columns*row) + cofile_col]);
        strcpy(&filedesc, data_row[((*file_bufr)->columns * row) + desc_col]);
        strcpy(&filetype, data_row[((*file_bufr)->columns * row) + type_col]);

        _pdm_debug("cifilename = <%s>", cifilename);
        _pdm_debug("cofilename = <%s>", cofilename);
        _pdm_debug("filedesc = <%s>", filedesc);
        _pdm_debug("filetype = <%s>", filetype);

	if ((chg_list->cpr_local_fn) && 
            (strcmp(chg_list->cpr_local_fn, cofilename) == 0) &&
            (chg_list->cpr_storage_fn) && 
            (strcmp(chg_list->cpr_storage_fn, cifilename) == 0) &&
            (chg_list->cpr_file_desc) && 
            (strcmp(chg_list->cpr_file_desc, filedesc) == 0) &&
            (chg_list->cpr_file_type) && 
            (strcmp(chg_list->cpr_file_type, filetype) == 0))
          {
          /* write change information to file_bufr */

          if (strlen (chg_list->cpr_chg_local_fn ))
            {
            _pdm_debug("writing new local filename", 0);
            status = MEMwrite_data(*file_bufr, chg_list->cpr_chg_local_fn,
                                   row + 1, cofile_col + 1);
            _pdm_status("MEMwrite_data", status);
            if (status != MEM_S_SUCCESS)
              return(PDM_E_WRITE_BUFFER);

            status = MEMwrite_data(*file_bufr, "Y", row + 1, status_col + 1);
            _pdm_status("MEMwrite_data", status);
            if (status != MEM_S_SUCCESS)
              return(PDM_E_WRITE_BUFFER);
            }
     
          if (strlen (chg_list->cpr_chg_storage_fn ))
            {
            _pdm_debug("writing new storage filename", 0);
            status = MEMwrite_data(*file_bufr, chg_list->cpr_chg_storage_fn,
                                   row + 1, cifile_col + 1);
            _pdm_status("MEMwrite_data", status);
            if (status != MEM_S_SUCCESS)
              return(PDM_E_WRITE_BUFFER);

            status = MEMwrite_data(*file_bufr, "Y", row + 1, status_col + 1);
            _pdm_status("MEMwrite_data", status);
            if (status != MEM_S_SUCCESS)
              return(PDM_E_WRITE_BUFFER);
            }
     
          if (strlen (chg_list->cpr_chg_file_desc ))
            {
            _pdm_debug("writing new file desc", 0);
            status = MEMwrite_data(*file_bufr, chg_list->cpr_chg_file_desc,
                                   row + 1, desc_col + 1);
            _pdm_status("MEMwrite_data", status);
            if (status != MEM_S_SUCCESS)
              return(PDM_E_WRITE_BUFFER);

            status = MEMwrite_data(*file_bufr, "Y", row + 1, status_col + 1);
            _pdm_status("MEMwrite_data", status);
            if (status != MEM_S_SUCCESS)
              return(PDM_E_WRITE_BUFFER);
            }
     
          if (strlen (chg_list->cpr_chg_file_type ))
            {
            _pdm_debug("writing new file type", 0);
            status = MEMwrite_data(*file_bufr, chg_list->cpr_chg_file_type,
                                   row + 1, type_col + 1);
            _pdm_status("MEMwrite_data", status);
            if (status != MEM_S_SUCCESS)
              return(PDM_E_WRITE_BUFFER);

            status = MEMwrite_data(*file_bufr, "Y", row + 1, status_col + 1);
            _pdm_status("MEMwrite_data", status);
            if (status != MEM_S_SUCCESS)
              return(PDM_E_WRITE_BUFFER);
            }
          }
        }

   chg_list = chg_list->spm_next;
   }

  if (PDMdebug_on)
  MEMprint_buffer("modified file_bufr", *file_bufr, PDU_DEBUG_FILE);

  free(line);

  if (status == MEM_S_SUCCESS)
    status = PDM_S_SUCCESS;

  return(status);
}

int PDUmark_files_for_delete(file_bufr, delete_list)
MEMptr    *file_bufr;
struct file_info *delete_list;
{

  long    status = PDM_S_SUCCESS;
  int     cifile_col = 0;
  int     cofile_col = 0;
  int     row = 0;
  int     status_col = 0;
  char    cifilename[15];
  char    cofilename[15];
  char    **data_row;
  struct file_info *file_list = NULL;

  _pdm_debug("in the function PDUdelete_files_from_buffer", 0);

  if (!*file_bufr)
    return(PDM_E_NULL_BUFFER);

  if (!delete_list)
    return(PDM_E_NULL_FILE_LIST);

  if (PDMdebug_on)
  MEMprint_buffer("original file_bufr", *file_bufr, PDU_DEBUG_FILE);

  status = MEMbuild_array(*file_bufr);
  _pdm_status("MEMbuild_array", status);
  if (status != MEM_S_SUCCESS)
    return(PDM_E_BUILD_BUFFER_ARRAY);

  PDUsetup_buffer(*file_bufr, ROW, &data_row);

  status = PDUget_buffer_col(*file_bufr, "n_status", &status_col);
  if (status != PDM_S_SUCCESS)
    return(status);

  status = PDUget_buffer_col(*file_bufr, "n_cifilename", &cifile_col);
  if (status != PDM_S_SUCCESS)
    return(status);

  status = PDUget_buffer_col(*file_bufr, "n_cofilename", &cofile_col);
  if (status != PDM_S_SUCCESS)
    return(status);

  cifilename[0] = '\0';
  cofilename[0] = '\0';

  while (file_list)
    {
    for (row = 1; row < (*file_bufr)->rows; ++ row)
       {
       /* load file information from current row */
       strcpy(cifilename, data_row[((*file_bufr)->columns * row) + cifile_col]);
       strcpy(cofilename, data_row[((*file_bufr)->columns * row) + cofile_col]);

       _pdm_debug("local filename = <%s>", cofilename);
       _pdm_debug("storage filename = <%s>", cifilename);

       if ((strcmp(file_list->cpr_local_fn, cofilename) == 0) &&
           (strcmp(file_list->cpr_storage_fn, cifilename) == 0))
         {
         _pdm_debug("marking row for deletion", 0);
         status = MEMwrite_data(*file_bufr, "Y", row + 1, status_col + 1);
         _pdm_status("MEMwrite_data", status);
         if (status != MEM_S_SUCCESS)
           return(PDM_E_WRITE_BUFFER);
         }
       }
       
       file_list = file_list->spm_next;
    }

  if (PDMdebug_on)
  MEMprint_buffer("modified file_bufr", *file_bufr, PDU_DEBUG_FILE);

  if (status == MEM_S_SUCCESS)
    status = PDM_S_SUCCESS;

  return(status);
}
