#include        <stdio.h>
#include        <FI.h>
#include        <PDUstr.h>
#include        <PDUextdef.h>
#include        <PDUerror.h>
#include        <PDUuser.h>
#include        <PDMtypes.h>
#include        <MEMerrordef.h>
#include        <NFMerrordef.h>
#include        "part_gadgets.h"
#include        "PDUforms.h"
#include        "PDUcommand.h"
#include        "PDUfile_def.h"
#include        "PDUstorage.h"
#include        "PDUprompt.h"
#include        <exdef.h>
#include        <PDUproto.h>
#include        <PDMproto.h>
#include        <sys/stat.h>

/* Extern */
 
extern int          PDM_debug_on;
extern int          PDU_add_files;
extern int          PDU_simmode_copy;
extern int          PDU_simmode_checkin;
extern int          PDU_command;
extern int          PDMdebug_on;
extern int          PDU_validate_access;
extern int          new_mode;
extern int          change_mode;
extern int          similar_mode;
extern int          review_mode;
extern struct       PDUforms   forms;
extern struct       PDUrefresh    *refresh;
extern struct       PDUuser       *user;
extern struct       PDUstorage    *storage;
extern char        *np_project;
extern char        *np_catalog;
extern char        *nn_itemname;
extern char        *np_rev;
extern char        *np_parttype;
extern char        *np_desc;
extern char        *ep_catalog;
extern char        *en_itemname;
extern char        *ep_rev;
extern char        *ep_parttype;
extern char        *PDU_save_filename;
extern char        *calloc();
extern char        *realloc();
extern MEMptr       PDU_attr_bufr;
extern MEMptr       PDU_data_bufr;
extern MEMptr       PDU_acl_bufr;
extern MEMptr       PDU_stg_bufr;
extern MEMptr       PDU_add_data_bufr;
extern char      ** PDU_attr_row;
extern char      ** PDU_file_list;
extern Form         PDU_form_id;
extern short        PDU_disable_localfn_col;
extern short        PDU_disable_storagefn_col;
extern short        PDU_disable_filetype_col;
extern short        PDU_disable_filedesc_col;
extern short        PDU_read_only_file;



PDUget_file_info_for_add_part()
  {
  char          * text = NULL;
  register int  ret_status = 0;
  int           text_length = 0;
  int           max_rows = 0;
  int           status = PDM_S_SUCCESS;
  int           row = 0;
  int           string_len;
  int           fildes[2];
  char          path[80]; 
  char          answer[30];
  char          *prompt = NULL;
  char       ** add1_data_col;
  int           i = 0;
  int           pos = 0;
  int           row_length = 0;
  int           max_row_length = 0;
  int           select_flag;
  int           n_cofilenm_col = 0;
  int           n_cifilenm_col = 0;
  int           n_filetype_col = 0;
  int           n_cisaname_col = 0;
  int           p_filedesc_col = 0;
  char        * string = NULL;
  char        * max_row_text = NULL;
  char        * cisaname_text = NULL;
  char        * cofile_text = NULL;
  char        * cifile_text = NULL;
  char        * filetype_text = NULL;
  char        * filedesc_text = NULL;
  char        * old_local_file = NULL;
  Form          form;
  int           field = 0;
  int           file_col = 0;
  int           strg_file_col = 0;
  int           file_type_col = 0;
  int           length = 0;
  pid_t         child = 0;
  char          dir_entry_name[1024];
  char          *save_filename = NULL;
  char          *msg = NULL;
  mode_t        mode;
  short         file_copied = FALSE;
  MEMptr        assy_bufr = NULL;


  _pdm_debug("in the function PDUget_file_info_for_add_part", 0);

  form = forms.part_operations_form_id;
  mode = S_IRUSR | S_IRGRP | S_IROTH | S_IWUSR | S_IWGRP;
 
  if (new_mode == TRUE)
    {
    field = FILE_INFO_MCF;
    file_col = 1;
    strg_file_col = 2;
    file_type_col = 3;
    }
  else if (similar_mode == TRUE)
    {
    field = SIMILAR_MODE_MCF;
    file_col = 2;
    strg_file_col = 3;
    file_type_col = 4;
    }

  status = MEMopen(&PDU_add_data_bufr, 512);
  _pdm_status("MEMopen",status);

  if (status != MEM_S_SUCCESS)
     {
     _pdm_debug("MEMopen failed", 0);
     return(status);
     }

  status = MEMwrite_format(PDU_add_data_bufr,"n_cofilename",
                           "char(14)");
  _pdm_status("MEMwrite_format",status);

  if (status != MEM_S_SUCCESS)
     {
     _pdm_debug("MEMwrite_format failed", 0);
     return(status);
     }

  status = MEMwrite_format(PDU_add_data_bufr,"n_filetype","char(10)");
  _pdm_status("MEMwrite_format",status);

  if (status != MEM_S_SUCCESS)
     {
     _pdm_debug("MEMwrite_format failed", 0);
     return(status);
     }

  status = MEMwrite_format(PDU_add_data_bufr,"n_cisaname","char(30)");
  _pdm_status("MEMwrite_format",status);

  if (status != MEM_S_SUCCESS)
     {
     _pdm_debug("MEMwrite_format failed", 0);
     return(status);
     }

  status = MEMwrite_format(PDU_add_data_bufr,"n_cifilename",
                           "char(14)");
  _pdm_status("MEMwrite_format",status);

  if (status != MEM_S_SUCCESS)
     {
     _pdm_debug("MEMwrite_format failed", 0);
     return(status);
     }

  status = MEMwrite_format(PDU_add_data_bufr,"p_filedesc","char(40)");
  _pdm_status("MEMwrite_format",status);

  if (status != MEM_S_SUCCESS)
     {
     _pdm_debug("MEMwrite_format failed", 0);
     return(status);
     }

  /* Write files from FILE_INFO_MCF to PDU_add_data_bufr */
  _pdm_debug("ENTER: Writing files to PDU_add_data_bufr",0);

  status = MEMbuild_array(PDU_add_data_bufr);
  _pdm_status("MEMbuild_array",status);

  if (status != MEM_S_SUCCESS)
     {
     _pdm_debug("MEMbuild_array failed", 0);
     return(status);
     }
 
  add1_data_col = (char **) PDU_add_data_bufr->column_ptr;

  string =(char *) malloc (sizeof (char) * PDU_add_data_bufr->row_size);
  memset(string, NULL, (sizeof (char) * PDU_add_data_bufr->row_size));

  for (i = 0; i < PDU_add_data_bufr->columns; ++i)
      string[i] = '\1';

  /* Writing a blank first row to PDU_add_data_bufr because it is
               required by NFM */

  status = MEMwrite(PDU_add_data_bufr,string);
  _pdm_status("MEMwrite",status);

  if (status != MEM_S_SUCCESS)
     {
     _pdm_debug("MEMwrite was UNsuccessful when writing string",0);
     return(status);
     }

  status = MEMbuild_array(PDU_add_data_bufr);
  _pdm_status("MEMbuild_array",status);

  if (status != MEM_S_SUCCESS)
     {
     _pdm_debug("MEMbuild_array failed", 0);
     return(status);
     }

  FIfld_get_num_rows(form,field, &max_rows);

  /* Test if the bottom row of the mcf is blank */
  _pdm_debug("checking for extra rows in mcfs", 0);
  if (new_mode == TRUE)
     {
     for (i = max_rows - 1; i > -1; --i)
        {
        FIfld_get_text_length(form, FILE_INFO_MCF, i, 1, &max_row_length);
        max_row_text = (char *)malloc(sizeof(char)*max_row_length+1);
        memset(max_row_text,NULL,sizeof (char) * max_row_length + 1);
        FIfld_get_text (form, FILE_INFO_MCF, i, 1, 
                max_row_length+1, (unsigned char *)max_row_text,
                &select_flag, &pos );
        if ((max_row_text == NULL) || (strcmp(max_row_text,"") == 0))
           {
           max_rows = max_rows - 1;
           _pdm_debug("empty row in MCF; decrementing max_rows", 0);
           _pdm_debug("max_rows = %d", max_rows);
           }
        }
     FIfld_set_num_rows(form, FILE_INFO_MCF, max_rows);
     _pdm_debug("setting number of rows to %d", (char *)max_rows);
     }

  if (similar_mode == TRUE)
     {
     for (i = max_rows - 1; i > -1; --i)
        {
        _pdm_debug("checking local file column", 0);
        FIfld_get_text_length(form, SIMILAR_MODE_MCF, i,2, &max_row_length);
        max_row_text = (char *)malloc(sizeof(char)*max_row_length+1);
        memset(max_row_text,NULL,sizeof (char) * max_row_length + 1);
        FIfld_get_text (form, SIMILAR_MODE_MCF, i, 2, 
               max_row_length+1, (unsigned char *)max_row_text,
               &select_flag, &pos );
        if ((max_row_text == NULL) || (strcmp(max_row_text,"") == 0))
           {
           _pdm_debug("checking existing file column", 0);
           FIfld_get_text_length(form, SIMILAR_MODE_MCF, i,1, &max_row_length);
           max_row_text = (char *)malloc(sizeof(char)*max_row_length+1);
           memset(max_row_text,NULL,sizeof (char) * max_row_length + 1);
           FIfld_get_text(form, SIMILAR_MODE_MCF, i, 1, max_row_length+1, 
                          (unsigned char *)max_row_text, &select_flag, &pos );
           if ((max_row_text == NULL) || (strcmp(max_row_text,"") == 0))
             {
             max_rows = max_rows - 1;
             _pdm_debug("empty row in MCF; decrementing max_rows", 0);
             _pdm_debug("max_rows = %d", max_rows);
             }
           }
        }
     FIfld_set_num_rows(form, SIMILAR_MODE_MCF, max_rows);
     _pdm_debug("setting number of rows to %d", (char *)max_rows);
     }

  if (max_row_text)
     {
     free(max_row_text);
     max_row_text = NULL;
     }

  if (PDMdebug_on)
    MEMprint_buffer("PDU_add_data_bufr", PDU_add_data_bufr, PDU_DEBUG_FILE);

  if (PDU_disable_localfn_col == FALSE)
     {
/*
     status = PDUget_col_number(PDU_add_data_bufr,"n_cofilename",
                                add1_data_col, &n_cofilenm_col);
*/
     status = PDUget_buffer_col(PDU_add_data_bufr, "n_cofilename", &n_cofilenm_col);
     if (status != PDM_S_SUCCESS)
        {
        PDUmessage(status,'s');
        return (status);
        }
     }
  if (PDU_disable_storagefn_col == FALSE)
     {
/*
     status = PDUget_col_number(PDU_add_data_bufr,"n_cifilename",
                                add1_data_col, &n_cifilenm_col);
*/
     status = PDUget_buffer_col(PDU_add_data_bufr,"n_cifilename",&n_cifilenm_col);
     if (status != PDM_S_SUCCESS)
        {
        PDUmessage(status,'s');
        return (status);
        }
     }
  if (PDU_disable_filetype_col == FALSE)
     {
/*
     status = PDUget_col_number(PDU_add_data_bufr,"n_filetype",
                                add1_data_col, &n_filetype_col);
*/
     status = PDUget_buffer_col(PDU_add_data_bufr,"n_filetype",&n_filetype_col);
     if (status != PDM_S_SUCCESS)
        {
        PDUmessage(status,'s');
        return (status);
        }
     }
  if (PDU_disable_filedesc_col == FALSE)
     {
/*
     status = PDUget_col_number(PDU_add_data_bufr,"p_filedesc",
                                add1_data_col, &p_filedesc_col);
*/
     status = PDUget_buffer_col(PDU_add_data_bufr,"p_filedesc",&p_filedesc_col);
     if (status != PDM_S_SUCCESS)
        {
        PDUmessage(status,'s');
        return (status);
        }
     }

/*
  status = PDUget_col_number(PDU_add_data_bufr, "n_cisaname",
                             add1_data_col, &n_cisaname_col);
  _pdm_status("PDUget_col_number",status);
*/
  status = PDUget_buffer_col(PDU_add_data_bufr, "n_cisaname",&n_cisaname_col);

  if (status != PDM_S_SUCCESS)
     {
     PDUmessage(status,'s');
     return (status);
     }

  FIfld_get_text_length(form, STORAGE_AREA_FLD, 0, 0, &length);
  text = (char *) malloc (sizeof (char) * length + 1);
  memset(text, NULL, sizeof (char) * length + 1);
  FIfld_get_text (form, STORAGE_AREA_FLD, 0, 0, length + 1, 
                  (unsigned char *)text, &select_flag, &pos );
  _pdm_debug("STORAGE_AREA_FLD = <%s>",text);
  if ((text) && (strcmp(text, "") != 0))
    PDUfill_in_string1(&cisaname_text, text);

  if ((PDMdebug_on) && (PDU_add_data_bufr))
    MEMprint_buffer("PDU_add_data_bufr",PDU_add_data_bufr, PDU_DEBUG_FILE);

  status = MEMbuild_array(PDU_add_data_bufr);
  _pdm_status("MEMbuild_array",status);

  if (status != MEM_S_SUCCESS)
     {
     _pdm_debug("MEMbuild_array FAILED", 0);
     status = PDM_E_BUILD_BUFFER_ARRAY;
     return(status);
     }

  if (PDU_simmode_copy == FALSE)
     {
     _pdm_debug("Mode is NEW MODE or (SIMILAR MODE and SIMMODE_COPY_TGL is toggled to DO NOT COPY)",0);
     _pdm_debug("mcf has %d rows", max_rows);
     if (max_rows == 0)
       {
       _pdm_debug("No files will be added while adding the part",0);

       _pdm_debug("checking PDU_add_data_bufr", 0);
       if (PDU_add_data_bufr)
         {
         _pdm_debug("setting PDU_add_data_bufr to NULL", 0);
         MEMclose(&PDU_add_data_bufr);
         PDU_add_data_bufr = NULL;
         }
       }
     else
       {
       for (row = 0; row < max_rows; ++row)
        {
        if (PDU_disable_localfn_col == FALSE)
           {
           FIfld_get_text_length(form,field,row,file_col,&row_length);
           cofile_text = (char*)malloc(sizeof(char)*row_length+1);
           memset(cofile_text, NULL, sizeof (char)*row_length+1);
           FIfld_get_text (form, field, row, file_col, row_length+1, 
                           (unsigned char *)cofile_text, &select_flag, &pos );
           _pdm_debug("cofile_text = <%s>", cofile_text);

           if ((cofile_text == NULL) || (strcmp(cofile_text,"") == 0)) 
              {
              msg = (char *) PDUtranslate_message(PDM_E_ENTER_FILENAME);
              FIg_set_text(PDU_form_id,FI_MSG_FIELD, msg);
              status = PDM_E_ENTER_FILENAME;
              PDUmessage(status, 's');
              return(status);
              }

           _pdm_debug("writing string to PDU_add_data_bufr <%s>", string);
           status = MEMwrite(PDU_add_data_bufr,string);
           _pdm_status("MEMwrite",status);

           if (status != MEM_S_SUCCESS)
              {
              _pdm_debug("MEMwrite Failed", 0);
              return(status);
              }

           status = MEMbuild_array(PDU_add_data_bufr);
           _pdm_status("MEMbuild_array",status);

           if (status != MEM_S_SUCCESS)
              {
              _pdm_debug("MEMbuild_array FAILED", 0);
              status = PDM_E_BUILD_BUFFER_ARRAY;
              return(status);
              }

           status = MEMwrite_data(PDU_add_data_bufr,cofile_text,
                                  row + 2, n_cofilenm_col + 1);
           _pdm_status("MEMwrite_data",status);

           if (status != MEM_S_SUCCESS)
              {
              _pdm_debug("MEMwrite_data Failed", 0);
              return(status);
              }
           }

        if (PDU_disable_storagefn_col == FALSE)
           {
           FIfld_get_text_length(form, field, row,strg_file_col, &row_length);
           cifile_text = (char*)malloc(sizeof(char)*row_length+1);
           memset(cifile_text,NULL,(sizeof(char) *row_length+1));
           FIfld_get_text (form, field, row, strg_file_col, 
                     row_length+1, (unsigned char *)cifile_text,
                     &select_flag, &pos );

           if ((cifile_text != NULL) && 
               (strcmp(cifile_text,"") != 0))
              {
              status = MEMbuild_array(PDU_add_data_bufr);
              _pdm_status("MEMbuild_array",status);
   
              if (status != MEM_S_SUCCESS)
                 {
                 _pdm_debug("MEMbuild_array FAILED", 0);
                 status = PDM_E_BUILD_BUFFER_ARRAY;
                 return(status);
                 }

              status = MEMwrite_data(PDU_add_data_bufr,cifile_text,
                                     row + 2, n_cifilenm_col + 1);
              _pdm_status("MEMwrite_data",status);

              if (status != MEM_S_SUCCESS)
                 {
                 _pdm_debug("MEMwrite_data Failed", 0);
                 return(status);
                 }
              }
            }

        if (PDU_disable_filetype_col == FALSE)
           {
           FIfld_get_text_length(form, field, row,file_type_col, &row_length);
           filetype_text=(char*)malloc(sizeof(char)* row_length+1);
           memset(filetype_text,NULL,(sizeof(char)*row_length+1));
           FIfld_get_text (form, field, row,file_type_col, 
                    row_length+1, (unsigned char *)filetype_text,
                    &select_flag, &pos );

           if ((filetype_text != NULL) &&
               (strcmp(filetype_text,"") != 0))
              {
              string_len = strlen(filetype_text);
              status = MEMbuild_array(PDU_add_data_bufr);
              _pdm_status("MEMbuild_array",status);

              if (status != MEM_S_SUCCESS)
                 {
                 _pdm_debug("MEMbuild_array FAILED", 0);
                 status = PDM_E_BUILD_BUFFER_ARRAY;
                 return(status);
                 }

              status = MEMwrite_data(PDU_add_data_bufr,filetype_text,
                                     row + 2, n_filetype_col + 1);
              _pdm_status("MEMwrite_data",status);

              if (status != MEM_S_SUCCESS)
                 {
                 _pdm_debug("MEMwrite_data Failed", 0);
                 return(status);
                 }
              }
           }

        if (PDU_disable_filedesc_col == FALSE)
           {
           FIfld_get_text_length(form, field, row,0, &row_length);
           filedesc_text=(char*)malloc(sizeof(char)*row_length+1);
           memset(filedesc_text,NULL,(sizeof(char)*row_length+1));
           FIfld_get_text (form, field, row,0, row_length+1, 
                           (unsigned char *)filedesc_text, &select_flag,&pos );

           if ((filedesc_text != NULL) && (strcmp(filedesc_text,"") != 0))
              {
              status = MEMbuild_array(PDU_add_data_bufr);
              _pdm_status("MEMbuild_array",status);

              if (status != MEM_S_SUCCESS)
                 {
                 _pdm_debug("MEMbuild_array FAILED", 0);
                 status = PDM_E_BUILD_BUFFER_ARRAY;
                 return(status);
                 }

              status = MEMwrite_data(PDU_add_data_bufr,filedesc_text,
                                     row + 2, p_filedesc_col + 1);
              _pdm_status("MEMwrite_data",status);

              if (status != MEM_S_SUCCESS)
                 {
                 _pdm_debug("MEMwrite_data Failed", 0);
                 return(status);
                 }
              }
           }

        status = MEMbuild_array(PDU_add_data_bufr);
        _pdm_status("MEMbuild_array",status);

        if (status != MEM_S_SUCCESS)
           {
           _pdm_debug("MEMbuild_array FAILED", 0);
           status = PDM_E_BUILD_BUFFER_ARRAY;
           return(status);
           }

        _pdm_debug("The cisaname_text before MEMwrite_data is <%s>",
                   cisaname_text);

        status = MEMwrite_data(PDU_add_data_bufr,cisaname_text,
                               row + 2, n_cisaname_col + 1);

        if (status != MEM_S_SUCCESS)
          return(PDM_E_WRITE_BUFFER);
        }
       }

     if (PDMdebug_on)
        MEMprint_buffer("PDU_add_data_bufr",PDU_add_data_bufr, PDU_DEBUG_FILE);

     /* Call the PDM function to add the part */
        status = PDMradd_part (np_project, np_catalog, nn_itemname, np_rev,
                               PDU_attr_bufr, PDU_data_bufr, 
                               PDU_add_data_bufr);
        _pdm_status("PDMradd_part", status);

        if (status == NFM_E_MESSAGE)
          status = PDM_E_FILE_NOT_FOUND;

        if (PDU_file_list)
          PDUfree_string_array(&PDU_file_list, max_rows);

        if (status != PDM_S_SUCCESS)
           {
           _pdm_debug("PDMradd_part was UNsuccessful",0);
           PDUmessage(status, 's');
           return(status);
           }
     }
  else if (PDU_simmode_copy == TRUE)
     {
     _pdm_debug("SIMILAR MODE = true and SIMMODE_COPY_TGL = TRUE",0);
     _pdm_debug("PDU_simmode_copy is equal to TRUE",0);

     /* Already set max_rows according to what is in the
        SIMILAR_MODE_MCF */

     if (PDMdebug_on)
        MEMprint_buffer("PDU_add_data_bufr before adding file info",
                     PDU_add_data_bufr, PDU_DEBUG_FILE);

     if (max_rows >= 1)
       {
       _pdm_debug("creating file list", 0);
       PDU_file_list = (char **) malloc (sizeof (char *) * max_rows);
       memset(PDU_file_list, NULL, sizeof (char *) * max_rows);

       for (i = 0; i < max_rows; ++i)
         {
         FIfld_get_text_length(form,field,i,2, &text_length);
         cofile_text = (char *) malloc (sizeof (char) * text_length + 1);
         memset(cofile_text,NULL,(sizeof(char) * text_length+1));
         FIfld_get_text (form, field, i, 2, text_length+1,
                         (unsigned char *)cofile_text, &select_flag, &pos );
 
         PDUfill_in_string(&PDU_file_list[i], cofile_text);
         _pdm_debug("PDU_file_list = <%s>", cofile_text);
         }
       }

     _pdm_debug("check to see if from part is an assembly", 0);
     _pdm_debug("retrieving structure of part <%s>", refresh->rev_partid);
     status = PDMget_assembly_structure(refresh->rev_catalog,
            refresh->rev_partid, refresh->rev_revision, 50, &assy_bufr, 0);
     _pdm_status("PDMget_assembly_structure", status);

     if (assy_bufr)
       {
       MEMclose(&assy_bufr);
       assy_bufr = NULL;
       }

     if (status == PDM_S_SUCCESS)
       {
       _pdm_debug("invoking automatic checkin", 0);
       if (!PDU_simmode_checkin)
         {
         FIg_set_state(forms.part_operations_form_id, SIMMODE_CHECKIN_TGL, 1);
         FIg_disable(forms.part_operations_form_id, SIMMODE_CHECKIN_TGL);
         PDU_simmode_checkin = TRUE;
         }
       }

     file_copied = FALSE;
     for (i = 0; i < max_rows; ++i)
         {
         FIfld_get_text_length(form,field,i,2, &text_length);
         cofile_text = (char *) malloc (sizeof (char) * text_length + 1);
         memset(cofile_text,NULL,(sizeof(char) * text_length+1));
         FIfld_get_text (form, field, i, 2, text_length+1, 
                         (unsigned char *)cofile_text, &select_flag, &pos );

         if (cofile_text == NULL)
            {
            /* Continue because a user may not copy all old files list to new 
               files, therefore, you need to go to the next row. */ 
            _pdm_debug("local filename is empty; skipping row %d", (char *)i);
            continue;
            }
         else if (strcmp(cofile_text,"") == 0)
            {
            _pdm_debug("local filename is empty; skipping row %d", (char *)i);
            continue;
            }
         else
            {
            status = MEMwrite(PDU_add_data_bufr,string);
            _pdm_status("MEMwrite",status);

            if (status != MEM_S_SUCCESS)
               {
               _pdm_debug("MEMwrite failed", 0);
               return(status);
               }

            _pdm_debug("The NEW LOCAL FILENAME <%s>",cofile_text);

            if (PDMdebug_on)
               MEMprint_buffer("PDU_add_data_bufr after string",
                               PDU_add_data_bufr, PDU_DEBUG_FILE);

            status = MEMbuild_array(PDU_add_data_bufr);
            _pdm_status("MEMbuild_array",status);

            if (status != MEM_S_SUCCESS)
               {
               _pdm_debug("MEMbuild_array failed", 0);
               return(status);
               }

            FIfld_get_text_length(form, field, i ,1, &text_length);
            old_local_file = (char *) malloc (sizeof (char) * text_length + 1);
            memset(old_local_file,NULL, (sizeof(char) * text_length+1));
            FIfld_get_text(form, field, i, 1, text_length+1, 
                           (unsigned char *)old_local_file, 
                           &select_flag, &pos );

            if ((old_local_file != NULL) && (strcmp(old_local_file,"") != 0))
               {
               _pdm_debug("OLD LOCAL FILENAME = <%s>", old_local_file);
               
               status = PDUverify_file(old_local_file);
               _pdm_debug("Verifying file exists locally <%s>",old_local_file);
               if (status == PDM_E_FILE_NOT_FOUND)
                  {
                  _pdm_debug("File <%s> is not local",old_local_file);
                  status = PDMrcheck_part_status(refresh->rev_catalog,
                            refresh->rev_partid, refresh->rev_revision);
                  _pdm_status("PDMrcheck_part_status", status);
                  PDUmessage(PDM_E_CLEAR_FIELD,'s');

                  /* if file does not exist locally and has never been checked
                     in, return error message */
                  if (status == PDM_I_NEVER_CHECKED_IN)
                    {
                    _pdm_debug("part files do not exist", 0);
                    PDUfill_in_string(&PDU_save_filename, old_local_file);
                    status = PDM_E_FILE_NOT_EXIST;
                    PDUmessage(status, 's');
                    return(status);
                    }
                  else if ((status == PDM_I_CHECKED_OUT_BY_YOU) ||
                           (status == PDM_I_CHECKED_OUT_BY_ANOTHER_USER) ||
                           (status == PDM_I_CHECKED_IN) ||
                           (status == PDM_I_COPIED_TO_LOCAL_BY_YOU) ||
                           (status == PDM_I_ATTACHED_TO_LOCAL_ASSY))
                     {
                     _pdm_debug("Copying file to local",0);
                     status = PDMscopy(refresh->rev_catalog,
                                    refresh->rev_partid, refresh->rev_revision, 
                                    old_local_file);
                     _pdm_status("PDMscopy", status);

                     if (status != PDM_S_SUCCESS)
                        {
                        _pdm_debug("The file does not exist",0);
                        prompt = 
                            (char *)PDUtranslate_message(PDP_P_FILE_NOT_COPIED);
                        msg = 
                      (char *) PDUtranslate_message(PDM_I_NEW_FILE_NOT_CREATED);
                        FIg_set_text(PDU_form_id,FI_MSG_FIELD, msg);
                        UI_prompt(prompt);

                        do
                          {
                          PDUget_keyin( answer );
                          status = PDM_S_SUCCESS;

                          if ((strcmp(answer,"y")==0)||(strcmp(answer,"Y")==0))
                             {
                             _pdm_debug("Add filename without copying.", 0);
                             msg = 
                          (char *) PDUtranslate_message(PDM_I_ADD_FILE_NO_COPY);
                             FIg_set_text(PDU_form_id,FI_MSG_FIELD, msg);
                             status = PDUextract_file_info(i, n_cofilenm_col,
                                n_cifilenm_col,n_filetype_col, p_filedesc_col);
                             _pdm_status("PDUextract_file_info", status);

                             if (status != PDM_S_SUCCESS)
                               {
                               _pdm_debug("PDUextract_file_info failed", 0);
                               return(status);
                               }

                             status = MEMbuild_array(PDU_add_data_bufr);
                             _pdm_status("MEMbuild_array",status);
 
                             if (status != MEM_S_SUCCESS)
                                {
                                _pdm_debug("MEMbuild_array FAILED", 0);
                                status = PDM_E_BUILD_BUFFER_ARRAY;
                                return(status);
                                }

                             status = MEMwrite_data(PDU_add_data_bufr,
                                        cisaname_text, PDU_add_data_bufr->rows, 
                                        n_cisaname_col + 1);
                             _pdm_status("MEMwrite_data",status);
                     
                             if (status != MEM_S_SUCCESS)
                                return(status);
                     
                             if (PDMdebug_on)
                               MEMprint_buffer("PDU_add_data_bufr",
                                             PDU_add_data_bufr,PDU_DEBUG_FILE);
                             }
                          else if ((strcmp(answer,"n") == 0) ||
                                  (strcmp(answer,"N") == 0))
                             {
                             _pdm_debug("User does not want to continue",0);
                             if (i == 0)
                                {
                                msg = 
                              (char *)PDUtranslate_message(PDM_E_CMD_CANCELLED);
                                FIg_set_text(PDU_form_id,FI_MSG_FIELD, msg);
                                PDU_add_files = FALSE;
                                status = PDM_E_CMD_CANCELLED;
                                PDUmessage(status, 's');
                                return(status);
                                }
                             }
                          } while (status == PDM_E_INVALID_INPUT);
                        sprintf(prompt,"%s","                                  ");
                        prompt = 
                            (char *)PDUtranslate_message(PDM_E_CLEAR_FIELD);
                        UI_prompt(prompt);
                        return(status);
                        }
                     else if (status == PDM_S_SUCCESS)
                        {
                        file_copied = TRUE;
                        _pdm_debug("File was copied locally",0);

                        _pdm_debug("copying <%s>", old_local_file);
                        _pdm_debug("new file = <%s>", cofile_text);
	
                        /* Save the seed file name and path so the
                           seed file can be removed later */

                        status = PDUcheck_if_graphic(old_local_file);
                        _pdm_status("PDUcheck_if_graphic",status);

                        if (status == PDM_S_SUCCESS)
                           {
                           _pdm_debug("File is graphic",0);
                           _pdm_debug("Do a copyOS",0);

                           _pdm_debug("Getting path of EXNUC", 0);
                           status = PDUget_exnuc_path(path);
                           _pdm_status("PDUget_exnuc_path returns", status);

                           if (status != PDM_S_SUCCESS)
                              {
                              _pdm_debug("failed to get EXNUC path", 0);
                              }

                           if (status == PDM_S_SUCCESS)
                              {
                              strcat(path, "bin/copyOS");
                              _pdm_debug("Path is <%s>", path);

#if defined (__sgi)
                              if ((child = fork()) == -1)
                                {
                                _pdm_debug("FORK did not work",0);
                                break;
                                }
#else
                              if ((child = vfork()) == -1)
                                {
                                _pdm_debug("VFORK did not work",0);
                                break;
                                }
#endif
                             else if((child == 0)) /* child=0. Do the copyOS */
                                {
                                _pdm_debug("Execute the copyOS",0);

                                _pdm_debug("checking filenames", 0);
                                if ((strcmp(old_local_file, cofile_text) == 0))
                                  {
                                  _pdm_debug("filenames are duplicate", 0);
                                  _pdm_debug("copyOS to temp file", 0);
                                  ret_status=execlp(path,path,
                                        old_local_file, ".pdutempOS",(char *)0);
                                  }
                                else
                                  {
                                  _pdm_debug("call execlp 1",0);
                                  ret_status=execlp(path,path,
                                        old_local_file, cofile_text,(char *)0);
                                  _pdm_debug("returned from execlp",0);
                                  }
                                if (ret_status == -1)
                                   {
                                   msg = (char *)
                                  PDUtranslate_message(PDM_E_COPY_OBJECT_SPACE);
                                   FIg_set_text(PDU_form_id, FI_MSG_FIELD,msg);
                                   PDUmessage(PDM_E_COPY_OBJECT_SPACE, 's');
                                   _pdm_debug("copyOS was UNsuccessful",0);
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

/*
                              status = PDUdelete_single_local_file();
                              _pdm_status("PDUdelete_single_local_file",status);

                              if (status != PDM_S_SUCCESS)
                              _pdm_debug("ERROR removing the seed file",0);
*/

                              if ((strcmp(old_local_file, cofile_text) == 0))
                                {
                                _pdm_debug("copyOS pdutempOS to filename", 0);
                                status = PDUverify_file(cofile_text);
                                _pdm_debug("PDUverify_file", status);
                                if (status != PDM_S_SUCCESS)
                                {
#if defined (__sgi)
                                if ((child = fork()) == -1)
                                  {
                                  _pdm_debug("FORK did not work",0);
                                  break;
                                  }
#else
                                if ((child = vfork()) == -1)
                                  {
                                  _pdm_debug("VFORK did not work",0);
                                  break;
                                  }
#endif
                               else if((child == 0)) /*child=0. Do the copyOS */
                                  {
                                  _pdm_debug("Execute the copyOS",0);
 
                                  _pdm_debug("call execlp 2",0); 
                                  ret_status=execlp(path,path,
                                       ".pdutempOS", cofile_text,(char *)0);
                                  _pdm_debug("returned from execlp",0);
                                  }
                                if (ret_status == -1)
                                   {
                                   msg = (char *)
                                  PDUtranslate_message(PDM_E_COPY_OBJECT_SPACE);
                                   FIg_set_text(PDU_form_id, FI_MSG_FIELD,msg);
                                   PDUmessage(PDM_E_COPY_OBJECT_SPACE, 's');
                                   _pdm_debug("copyOS was UNsuccessful",0);
                                   break;
                                   }
                                else
                                   {
                                   _pdm_debug("The copyOS was Successful",0);
                                   }
  
                                if (waitpid(child,NULL,0) < 0)
                                  _pdm_debug("Wait Error", 0);
                                }

                                _pdm_debug("removing pdutempOS", 0);
                                strcpy(dir_entry_name,user->wrkst_cwd);
                                strcat(dir_entry_name,"/.pdutempOS");
                                _pdm_debug("path name = <%s>",dir_entry_name);
                                status = unlink(dir_entry_name);
                                if (status == 0)
                                   {
                                    _pdm_debug("entry <%s> was removed",
                                               dir_entry_name);
                                   }
                                else
                                   {
                                    _pdm_debug("entry <%s> removal failed",
                                               dir_entry_name);
                                   }
                                }
                              }

                           }
                        else
                           {
                           _pdm_debug("File is NOT graphic",0);
                           _pdm_debug("Do a unix copy",0);
                           strcpy(path, "/bin/cp");
                           _pdm_debug("Path is <%s>", path);
                           /* fill in filename from buffer for copy file */
                           if (pipe(fildes) == 0)
                              {
#if defined (__sgi)
                              if (ret_status = fork())
                                 {
                                 if (ret_status != -1)
                                    {
                                    close(fildes[0]);
                                    close(fildes[1]);
                                    }
                                 }
#else
                              if (ret_status = vfork())
                                 {
                                 if (ret_status != -1)
                                    {
                                    close(fildes[0]);
                                    close(fildes[1]);
                                    }
                                 }
#endif
                              else
                                 {
                                 close(fileno(stdout));
                                 dup(fildes[1]);
                                 close(fildes[1]);
                                 if (strcmp(old_local_file, cofile_text) == 0)
                                   {
                                   _pdm_debug("filenames are duplicate", 0);
                                   execl(path, path, old_local_file,
                                         ".pdutempOS", (char *)0);
                                   }
                                 else
                                   {
                                   _pdm_debug("filenames are different", 0);
                                   execl(path, path, old_local_file,
                                         cofile_text, (char *)0);
                                   }
                                 }
                              }
                           /* Remove the seed file that was copied locally */

/*
                           status = PDUdelete_single_local_file();
                           _pdm_status("PDUdelete_single_local_file",status);

                           if (status != PDM_S_SUCCESS)
                           _pdm_debug("ERROR removing the seed file from local directory",0);
*/
                           if (strcmp(old_local_file, cofile_text) == 0)
                             {
                             _pdm_debug("copy pdutempOS to filename", 0);
                             status = PDUverify_file(cofile_text);
                             _pdm_debug("PDUverify_file", status);
                             if (status != PDM_S_SUCCESS)
                               {
                               if (pipe(fildes) == 0)
                                  {
#if defined (__sgi)
                                  if (ret_status = fork())
                                     {
                                     if (ret_status != -1)
                                        {
                                        close(fildes[0]);
                                        close(fildes[1]);
                                        }
                                      }
#else
                                  if (ret_status = vfork())
                                     {
                                     if (ret_status != -1)
                                        {
                                        close(fildes[0]);
                                        close(fildes[1]);
                                        }
                                     }
#endif
                                  else
                                     {
                                     close(fileno(stdout));
                                     dup(fildes[1]);
                                     close(fildes[1]);
                                     execl(path, path, ".pdutempOS",
                                           cofile_text, (char *)0);
                                     }
                                  }
                               }

                                _pdm_debug("removing pdutempOS", 0);
                                strcpy(dir_entry_name,user->wrkst_cwd);
                                strcat(dir_entry_name,"/.pdutempOS");
                                _pdm_debug("path name = <%s>",dir_entry_name);
                                status = unlink(dir_entry_name);
                                if (status == 0)
                                   {
                                    _pdm_debug("entry <%s> was removed",
                                               dir_entry_name);
                                   }
                                else
                                   {
                                    _pdm_debug("entry <%s> removal failed",
                                               dir_entry_name);
                                   }
                             }
                           }

                        status = PDUextract_file_info(i, n_cofilenm_col,
                                n_cifilenm_col,n_filetype_col, p_filedesc_col);
                        _pdm_status("PDUextract_file_info", status);

                        if (status != PDM_S_SUCCESS)
                          {
                          _pdm_debug("PDUextract_file_info failed", 0);
                          return(status);
                          }

                        status = MEMbuild_array(PDU_add_data_bufr);
                        _pdm_status("MEMbuild_array",status);

                        if (status != MEM_S_SUCCESS)
                           {
                           _pdm_debug("MEMbuild_array FAILED", 0);
                           status = PDM_E_BUILD_BUFFER_ARRAY;
                           return(status);
                           }

                        status = MEMwrite_data(PDU_add_data_bufr,
                                  cisaname_text, PDU_add_data_bufr->rows, 
                                  n_cisaname_col + 1);
                        _pdm_status("MEMwrite_data", status);

                        if (status != MEM_S_SUCCESS)
                           {
                           _pdm_debug("MEMwrite_data failed", 0);
                           return(status);
                           }

                        if (PDMdebug_on)
                           MEMprint_buffer("PDU_add_data_bufr",
                             PDU_add_data_bufr, PDU_DEBUG_FILE);
                    
                        }
                     }
                  }
               else
                  {
                  _pdm_debug("The file <%s> is local",old_local_file);
                  if ((strcmp(old_local_file, cofile_text) == 0) && 
                      (!file_copied))
                    {
                    status = PDM_E_COPY_DUP_FILENAME;
                    msg = (char *)PDUtranslate_message(status);
                    FIg_set_text(PDU_form_id, FI_MSG_FIELD, msg);
                    PDUmessage(status, 's');
                    return(status);
                    }

                   _pdm_debug("checking to see if file is open", 0);
                   status = PDUis_file_open(old_local_file);
                   _pdm_status("PDUis_file_open", status);
                   if (status == 1)
                     {
                     status = PDM_E_COPY_OPEN_FILE;
                     PDUmessage(status, 's');
                     return(status);
                     }

                  PDUfill_in_string(&refresh->rev_filename, old_local_file);

                  _pdm_debug("checking file permissions", 0);
                  PDUfill_in_string(&save_filename, refresh->act_filename);
                  PDUfill_in_string(&refresh->act_filename, 
                                     refresh->rev_filename);
                  status = PDUcheck_file_permissions();
                  _pdm_status("PDUcheck_file_permissions", status);
                  if (!status)
                    PDU_read_only_file = TRUE;
                  PDUfill_in_string(&refresh->act_filename, save_filename);
                  status = PDM_S_SUCCESS;

                  status = PDUcheck_if_graphic(old_local_file);
                  _pdm_status("PDUcheck_if_graphic",status);

                  if (status == PDM_S_SUCCESS)
                     {
                     _pdm_debug("File is graphic",0);
                     _pdm_debug("Do a copyOS",0);

                     /* get path of exnuc on workstation */
                     _pdm_debug("Getting path of EXNUC", 0);
                     status = PDUget_exnuc_path(path);
                     _pdm_status("PDUget_exnuc_path returns", status);

                     if (status != PDM_S_SUCCESS)
                       {
                       _pdm_debug("failed to get EXNUC path", 0);
                       }

                     if (status == PDM_S_SUCCESS)
                        {
                        strcat(path, "bin/copyOS");
                        _pdm_debug("Path is <%s>", path);

                        _pdm_debug("copying <%s>", old_local_file);
                        _pdm_debug("new file = <%s>", cofile_text);
#if defined (__sgi)
                        if ((child = fork()) == -1)
                          {
                          _pdm_debug("FORK did not work",0);
                          break;
                          }
#else
                        if ((child = vfork()) == -1)
                          {
                          _pdm_debug("VFORK did not work",0);
                          break;
                          }
#endif
                       else if((child == 0)) /* child = 0. Do the copyOS */
                          {
                          _pdm_debug("Execute the copyOS",0);
                          if ((strcmp(old_local_file, cofile_text) == 0))
                              {
                              _pdm_debug("filenames are duplicate", 0);
 
                              _pdm_debug("copyOS to temp file", 0);
                              ret_status=execlp(path,path,
                                    old_local_file, ".pdutempOS",(char *)0);
                              }
                            else
                              {
                              _pdm_debug("call execlp 3",0);
                              _pdm_debug("path %s",path);
                              _pdm_debug("old_local_file %s",old_local_file);
                              _pdm_debug("cofile_text %s",cofile_text);
                              ret_status = execlp(path,path,old_local_file,
                                                  cofile_text,(char *)0);
                              _pdm_debug("returned from execlp",0);
                              }
                          if (ret_status == -1)
                            {
                            msg = (char *) PDUtranslate_message(PDM_E_COPY_OBJECT_SPACE);
                            FIg_set_text(PDU_form_id, FI_MSG_FIELD,msg);
                            PDUmessage(PDM_E_COPY_OBJECT_SPACE, 's');
                            _pdm_debug("The copyOS was UNsuccessful",0);
                            break;
                            }
                          else
                            {
                            _pdm_debug("The copyOS was Successful",0);
                            }
                          }
 
                        if (waitpid(child,NULL,0) < 0)
                          _pdm_debug("Wait Error", 0);
                        }
                     }
                  else
                     {
                     _pdm_debug("File is NOT graphic",0);
                     _pdm_debug("Do a unix copy",0);
                     strcpy(path, "/bin/cp");
                     _pdm_debug("Path is <%s>", path);
                     /* fill in filename fom buffer for copy file */
                     if (pipe(fildes) == 0)
                        {
#if defined (__sgi)
                        if (ret_status = fork())
                           {
                           if (ret_status != -1)
                              {
                              close(fildes[0]);
                              close(fildes[1]);
                              }
                            }
#else
                        if (ret_status = vfork())
                           {
                           if (ret_status != -1)
                              {
                              close(fildes[0]);
                              close(fildes[1]);
                              }
                           }
#endif
                        else
                           {
                           close(fileno(stdout));
                           dup(fildes[1]);
                           close(fildes[1]);
                           if (strcmp(old_local_file, cofile_text) == 0)
                               {
                               _pdm_debug("filenames are duplicate", 0);
                               execl(path, path, old_local_file,
                                     ".pdutempOS", (char *)0);
                               }
                             else
                               {
                               _pdm_debug("filenames are different", 0);
                               execl(path, path, old_local_file,
                                     cofile_text, (char *)0);
                               }
                           }
                        }                            
                     }

                  status = PDUextract_file_info(i, n_cofilenm_col,
                          n_cifilenm_col,n_filetype_col, p_filedesc_col);
                  _pdm_status("PDUextract_file_info", status);

                  if (status != PDM_S_SUCCESS)
                    {
                    _pdm_debug("PDUextract_file_info failed", 0);
                    return(status);
                    }

                  status = MEMbuild_array(PDU_add_data_bufr);
                  _pdm_status("MEMbuild_array",status);

                  if (status != MEM_S_SUCCESS)
                     {
                     _pdm_debug("MEMbuild_array FAILED", 0);
                     status = PDM_E_BUILD_BUFFER_ARRAY;
                     return(status);
                     }

                  status = MEMwrite_data(PDU_add_data_bufr,cisaname_text,
                                  PDU_add_data_bufr->rows, n_cisaname_col + 1);
                  _pdm_status("MEMwrite_data", status);

                  if (status != MEM_S_SUCCESS)
                     {
                     _pdm_debug("MEMwrite_data failed", 0);
                     return(status);
                     }
          
                  if (PDMdebug_on)
                     MEMprint_buffer("PDU_add_data_bufr",PDU_add_data_bufr,
                                     PDU_DEBUG_FILE);
                  }
               }
            else
               {
               _pdm_debug("There is no old local filename",0);
               _pdm_debug("Add file without copying a file",0);

               status = PDUextract_file_info(i, n_cofilenm_col,
                          n_cifilenm_col,n_filetype_col, p_filedesc_col);
               _pdm_status("PDUextract_file_info", status);

               if (status != PDM_S_SUCCESS)
                 {
                 _pdm_debug("PDUextract_file_info failed", 0);
                 return(status);
                 }

               status = MEMbuild_array(PDU_add_data_bufr);
               _pdm_status("MEMbuild_array",status);

               if (status != MEM_S_SUCCESS)
                  {
                  _pdm_debug("MEMbuild_array FAILED", 0);
                  status = PDM_E_BUILD_BUFFER_ARRAY;
                  return(status);
                  }

               status = MEMwrite_data(PDU_add_data_bufr,cisaname_text,
                               PDU_add_data_bufr->rows,
                               n_cisaname_col + 1);
               _pdm_status("MEMwrite_data", status);

               if (status != MEM_S_SUCCESS)
                  {
                  _pdm_debug("MEMwrite_data failed", 0);
                  return(status);
                  }

               if (PDMdebug_on)
                  MEMprint_buffer("PDU_add_data_bufr",PDU_add_data_bufr,
                                  PDU_DEBUG_FILE);
               }
            }

        _pdm_debug("resetting cofilename in data_bufr", 0);
        status = MEMbuild_array(PDU_data_bufr);
        _pdm_status("MEMbuild_array",status);
   
        if (status != MEM_S_SUCCESS)
           {
           _pdm_debug("MEMbuild_array FAILED", 0);
           status = PDM_E_BUILD_BUFFER_ARRAY;
           return(status);
           }
   
        PDUget_buffer_col(PDU_data_bufr, "n_cofilename", &file_col);
   
        status = MEMwrite_data(PDU_data_bufr,"",1, file_col + 1);
        _pdm_status("MEMwrite_data",status);
   
        if (status != MEM_S_SUCCESS)
           {
           _pdm_debug("MEMwrite_data Failed", 0);
           return(PDM_E_WRITE_BUFFER);
           }

        _pdm_debug("processing other columns in SIMILAR_MODE_MCF", 0);
        if (PDU_disable_storagefn_col == FALSE)
           {
           FIfld_get_text_length(form, field, row,strg_file_col, &row_length);
           cifile_text = (char*)malloc(sizeof(char)*row_length+1);
           memset(cifile_text,NULL,(sizeof(char) *row_length+1));
           FIfld_get_text (form, field, row, strg_file_col, 
                     row_length+1, (unsigned char *)cifile_text,
                     &select_flag, &pos );

           if ((cifile_text != NULL) && 
               (strcmp(cifile_text,"") != 0))
              {
              status = MEMbuild_array(PDU_add_data_bufr);
              _pdm_status("MEMbuild_array",status);
   
              if (status != MEM_S_SUCCESS)
                 {
                 _pdm_debug("MEMbuild_array FAILED", 0);
                 status = PDM_E_BUILD_BUFFER_ARRAY;
                 return(status);
                 }

              status = MEMwrite_data(PDU_add_data_bufr,cifile_text,
                                     row + 2, n_cifilenm_col + 1);
              _pdm_status("MEMwrite_data",status);

              if (status != MEM_S_SUCCESS)
                 {
                 _pdm_debug("MEMwrite_data Failed", 0);
                 return(status);
                 }
              }
            }

        if (PDU_disable_filetype_col == FALSE)
           {
           FIfld_get_text_length(form, field, row,file_type_col, &row_length);
           filetype_text=(char*)malloc(sizeof(char)* row_length+1);
           memset(filetype_text,NULL,(sizeof(char)*row_length+1));
           FIfld_get_text (form, field, row,file_type_col, 
                    row_length+1, (unsigned char *)filetype_text,
                    &select_flag, &pos );

           if ((filetype_text != NULL) &&
               (strcmp(filetype_text,"") != 0))
              {
              string_len = strlen(filetype_text);
              status = MEMbuild_array(PDU_add_data_bufr);
              _pdm_status("MEMbuild_array",status);

              if (status != MEM_S_SUCCESS)
                 {
                 _pdm_debug("MEMbuild_array FAILED", 0);
                 status = PDM_E_BUILD_BUFFER_ARRAY;
                 return(status);
                 }

              status = MEMwrite_data(PDU_add_data_bufr,filetype_text,
                                     row + 2, n_filetype_col + 1);
              _pdm_status("MEMwrite_data",status);

              if (status != MEM_S_SUCCESS)
                 {
                 _pdm_debug("MEMwrite_data Failed", 0);
                 return(status);
                 }
              }
           }

        if (PDU_disable_filedesc_col == FALSE)
           {
           FIfld_get_text_length(form, field, row,0, &row_length);
           filedesc_text=(char*)malloc(sizeof(char)*row_length+1);
           memset(filedesc_text,NULL,(sizeof(char)*row_length+1));
           FIfld_get_text (form, field, row,0, row_length+1, 
                           (unsigned char *)filedesc_text, &select_flag,&pos );

           if ((filedesc_text != NULL) && (strcmp(filedesc_text,"") != 0))
              {
              status = MEMbuild_array(PDU_add_data_bufr);
              _pdm_status("MEMbuild_array",status);

              if (status != MEM_S_SUCCESS)
                 {
                 _pdm_debug("MEMbuild_array FAILED", 0);
                 status = PDM_E_BUILD_BUFFER_ARRAY;
                 return(status);
                 }

              status = MEMwrite_data(PDU_add_data_bufr,filedesc_text,
                                     row + 2, p_filedesc_col + 1);
              _pdm_status("MEMwrite_data",status);

              if (status != MEM_S_SUCCESS)
                 {
                 _pdm_debug("MEMwrite_data Failed", 0);
                 return(status);
                 }
              }
           }
        }

     if (file_copied)
       {
       _pdm_debug("removing copied files", 0);
       status = PDUdelete_single_local_file();
       _pdm_status("PDUdelete_single_local_file",status);

       if (status != PDM_S_SUCCESS)
         _pdm_debug("ERROR removing the seed file",0);

       _pdm_debug("checking file permissions before add part", 0);
       if (max_rows >= 1)
         {
         for (i = 0; i < max_rows; ++i)
           {
           FIfld_get_text_length(form,field,i,2, &text_length);
           cofile_text = (char *) malloc (sizeof (char) * text_length + 1);
           memset(cofile_text,NULL,(sizeof(char) * text_length+1));
           FIfld_get_text (form, field, i, 2, text_length+1,
                           (unsigned char *)cofile_text, &select_flag, &pos );
    
           if (strcmp(cofile_text,"") == 0)
             break;
           else
             {
             status = PDUverify_file(cofile_text);
             _pdm_status("PDUverify_file", status);
             if (status == PDM_S_SUCCESS)
               {
               _pdm_debug("changing file permissions", 0);
               status = PDUchange_file_permissions( cofile_text, mode);
               _pdm_status("PDUchange_file_permissions", status);
               }
             }
           }
         }

       _pdm_debug("check to see if the from part has a 2.2 file", 0);
       status = PDUconvert_file_for_similar_mode(PDU_file_list,
						 max_rows);
       }

     /* Call the PDM function to add the part */
     status = PDMradd_part (np_project, np_catalog, nn_itemname, np_rev,
                            PDU_attr_bufr, PDU_data_bufr, PDU_add_data_bufr);
     _pdm_status("PDMradd_part", status);

     if (status == NFM_E_MESSAGE)
       status = PDM_E_FILE_NOT_FOUND;

     if (status != PDM_S_SUCCESS)
        {
        _pdm_debug("PDMradd_part was UNsuccessful",0);
        PDUmessage(status, 's');
        return(status);
        }

     }
  return(status);
  }

PDUextract_file_info(row, n_cofilenm_col, n_cifilenm_col, n_filetype_col,
                     p_filedesc_col)
  int     row;
  int     n_cofilenm_col;
  int     n_cifilenm_col;
  int     n_filetype_col;
  int     p_filedesc_col;
{
  Form    form;
  int     status = PDM_S_SUCCESS;
  int     field = 0;
  int     select_flag = 0;
  int     pos = 0;
  int     row_length = 0;
  int     file_col = 0;
  int     strg_file_col = 0;
  int     file_type_col = 0;
  static char        * cofile_text = NULL;
  static char        * cifile_text = NULL;
  static char        * filetype_text = NULL;
  static char        * filedesc_text = NULL;

  _pdm_debug("In the function PDUextract_file_info", 0);
  
  form = forms.part_operations_form_id;
 
  if (new_mode == TRUE)
    {
    field = FILE_INFO_MCF;
    file_col = 1;
    strg_file_col = 2;
    file_type_col = 3;
    }
  else if (similar_mode == TRUE)
    {
    field = SIMILAR_MODE_MCF;
    file_col = 2;
    strg_file_col = 3;
    file_type_col = 4;
    }

  FIfld_get_text_length(form,field,row,file_col,&row_length);
  cofile_text = (char *) malloc (sizeof (char) * row_length + 1);
  memset(cofile_text,NULL, (sizeof(char) * row_length+1));
  FIfld_get_text (form, field, row, file_col, row_length+1, 
                  (unsigned char *)cofile_text, &select_flag, &pos );
  _pdm_debug("cofile_text = <%s>", cofile_text);
  _pdm_debug("n_cofilenm_col = %d", (char *)n_cofilenm_col);

  if ((cofile_text != NULL) && (strcmp(cofile_text,"") != 0))
     {
     status = MEMbuild_array( PDU_add_data_bufr);
     _pdm_status("MEMbuild_array",status);

     if (status != MEM_S_SUCCESS)
        {
        _pdm_debug("MEMbuild_array FAILED", 0);
        status = PDM_E_BUILD_BUFFER_ARRAY;
        return(status);
        }

     status = MEMwrite_data( PDU_add_data_bufr, cofile_text, 
                             PDU_add_data_bufr->rows, n_cofilenm_col + 1);
     _pdm_status("MEMwrite_data",status);

     if (status != MEM_S_SUCCESS)
        {
        _pdm_debug("MEMwrite_data failed", 0);
        return(status);
        }
     }

  FIfld_get_text_length(form,field,row,strg_file_col,&row_length);
  cifile_text = (char *) malloc (sizeof (char) * row_length + 1);
  memset(cifile_text,NULL, (sizeof(char) * row_length+1));
  FIfld_get_text (form, field, row, strg_file_col, row_length+1, 
                  (unsigned char *)cifile_text, &select_flag, &pos );
  _pdm_debug("cifile_text = <%s>", cifile_text);
  _pdm_debug("n_cifilenm_col = %d", (char *)n_cifilenm_col);

  if ((cifile_text != NULL) && (strcmp(cifile_text,"") != 0))
     {
     status = MEMbuild_array( PDU_add_data_bufr);
     _pdm_status("MEMbuild_array",status);

     if (status != MEM_S_SUCCESS)
        {
        _pdm_debug("MEMbuild_array FAILED", 0);
        status = PDM_E_BUILD_BUFFER_ARRAY;
        return(status);
        }

     status = MEMwrite_data( PDU_add_data_bufr, cifile_text, 
                             PDU_add_data_bufr->rows, n_cifilenm_col + 1);
     _pdm_status("MEMwrite_data",status);

     if (status != MEM_S_SUCCESS)
        {
        _pdm_debug("MEMwrite_data failed", 0);
        return(status);
        }
     }

  FIfld_get_text_length(form,field,row,file_type_col,&row_length);
  filetype_text = (char *) malloc (sizeof (char) * row_length + 1);
  memset(filetype_text,NULL, (sizeof(char) * row_length+1));
  FIfld_get_text (form, field, row, file_type_col, row_length+1, 
                  (unsigned char *)filetype_text, &select_flag, &pos );
  _pdm_debug("filetype_text = <%s>", filetype_text);
  _pdm_debug("n_filetype_col = %d", (char *)n_filetype_col);

  if ((filetype_text != NULL) && (strcmp(filetype_text,"") != 0))
     {
     status = MEMbuild_array( PDU_add_data_bufr);
     _pdm_status("MEMbuild_array",status);

     if (status != MEM_S_SUCCESS)
        {
        _pdm_debug("MEMbuild_array FAILED", 0);
        status = PDM_E_BUILD_BUFFER_ARRAY;
        return(status);
        }

     status = MEMwrite_data( PDU_add_data_bufr, filetype_text, 
                             PDU_add_data_bufr->rows, n_filetype_col + 1);
     _pdm_status("MEMwrite_data",status);

     if (status != MEM_S_SUCCESS)
        {
        _pdm_debug("MEMwrite_data failed", 0);
        return(status);
        }
     }

  FIfld_get_text_length(form,field,row,0,&row_length);
  filedesc_text = (char *) malloc (sizeof (char) * row_length + 1);
  memset(filedesc_text,NULL, (sizeof(char) * row_length+1));
  FIfld_get_text (form, field, row,0, row_length+1, 
                  (unsigned char *)filedesc_text, &select_flag,&pos );
  _pdm_debug("filedesc_text = <%s>", filedesc_text);
  _pdm_debug("p_filedesc_col = %d", (char *)p_filedesc_col);

  if ((filedesc_text != NULL) && (strcmp(filedesc_text,"") != 0))
     {
     status = MEMbuild_array( PDU_add_data_bufr);
     _pdm_status("MEMbuild_array",status);

     if (status != MEM_S_SUCCESS)
        {
        _pdm_debug("MEMbuild_array FAILED", 0);
        status = PDM_E_BUILD_BUFFER_ARRAY;
        return(status);
        }

     status = MEMwrite_data( PDU_add_data_bufr, filedesc_text, 
                             PDU_add_data_bufr->rows, p_filedesc_col + 1);
     _pdm_status("MEMwrite_data",status);

     if (status != MEM_S_SUCCESS)
        {
        _pdm_debug("MEMwrite_data failed", 0);
        return(status);
        }
     }
  if (status == MEM_S_SUCCESS)
    status = PDM_S_SUCCESS;
  return(status);
}

int PDUprocess_catalog_parttype()
{
   _pdm_debug("In the function PDUprocess_catalog_parttype", 0);

   _pdm_debug("np_catalog = <%s>", np_catalog);
   _pdm_debug("np_parttype = <%s>", np_parttype);
   _pdm_debug("ep_catalog = <%s>", ep_catalog);
   _pdm_debug("ep_parttype = <%s>", ep_parttype);

   /* Fill in PART TYPE */
   if (((np_catalog != NULL) && (strcmp(np_catalog,"") != 0)) &&
       (np_parttype != NULL) && (strcmp(np_parttype,"") != 0) &&
       ((ep_parttype == NULL) || (strcmp(ep_parttype,"") == 0)))
      {
      FIfld_set_text(PDU_form_id,EP_PARTTYPE_FLD,0,0,np_parttype,FALSE);
      PDUfill_in_string1(&ep_parttype,np_parttype);
      PDUfill_in_string1(&refresh->rev_parttype,np_parttype);
      return(PDM_S_SUCCESS);
      }

   if ((np_catalog) && (strcmp(np_catalog,"pdmlibraries") == 0))
     {
     FIg_set_text(forms.part_operations_form_id,NP_PARTTYPE_FLD,"M");
     PDUfill_in_string1(&np_parttype, "M");
     PDUfill_in_string1(&refresh->new_parttype,np_parttype);
     FIg_disable(forms.part_operations_form_id,NP_PARTTYPE_BTN);

     if (similar_mode)
       {
       if ((!en_itemname) || (en_itemname && (!(strlen(en_itemname)))))
         {
         FIg_set_text(forms.part_operations_form_id,EP_PARTTYPE_FLD,"M");
         PDUfill_in_string1(&ep_parttype, "M");
         PDUfill_in_string1(&refresh->rev_parttype,ep_parttype);
         }
       FIg_disable(forms.part_operations_form_id,EP_PARTTYPE_BTN);
       }

     FIfld_pos_cursor(PDU_form_id,NP_PARTNUM_FLD,0,0,0,0,0,0);
     return(PDM_S_SUCCESS);
     }

  else if ((np_catalog) && (strcmp(np_catalog,"pdmseedfiles") == 0))
     {
     FIg_set_text(forms.part_operations_form_id,NP_PARTTYPE_FLD,"G");
     PDUfill_in_string1(&np_parttype, "G");
     PDUfill_in_string1(&refresh->new_parttype,np_parttype);

     if (similar_mode)
       {
       FIg_set_text(forms.part_operations_form_id,EP_PARTTYPE_FLD,"G");
       PDUfill_in_string1(&ep_parttype, "G");
       PDUfill_in_string1(&refresh->rev_parttype,ep_parttype);
       FIg_disable(forms.part_operations_form_id,EP_PARTTYPE_BTN);
       }

     FIfld_pos_cursor(PDU_form_id,NP_PARTNUM_FLD,0,0,0,0,0,0);
     return(PDM_S_SUCCESS);
     }

   if ((ep_catalog) && (strcmp(ep_catalog,"pdmlibraries") == 0))
     {
     if ((!en_itemname) || (en_itemname && (!(strlen(en_itemname)))))
       {
       FIg_set_text(forms.part_operations_form_id,EP_PARTTYPE_FLD,"M");
       PDUfill_in_string1(&ep_parttype, "M");
       PDUfill_in_string1(&refresh->rev_parttype,ep_parttype);
       }
     FIg_disable(forms.part_operations_form_id,EP_PARTTYPE_BTN);
     FIfld_pos_cursor(PDU_form_id,EP_PARTNUM_FLD,0,0,0,0,0,0);
     return(PDM_S_SUCCESS);
     }
  else if ((ep_catalog) && (strcmp(ep_catalog,"pdmseedfiles") == 0))
     {
     FIg_set_text(forms.part_operations_form_id,EP_PARTTYPE_FLD,"G");
     PDUfill_in_string1(&ep_parttype, "G");
     PDUfill_in_string1(&refresh->rev_parttype,ep_parttype);
     FIfld_pos_cursor(PDU_form_id,EP_PARTNUM_FLD,0,0,0,0,0,0);
     return(PDM_S_SUCCESS);
     }

   _pdm_debug("ep_catalog = <%s>", ep_catalog);
   _pdm_debug("ep_parttype = <%s>", ep_parttype);

   if ((np_parttype) && ((strcmp(np_parttype,"N") == 0) ||
                         (strcmp(np_parttype,"n") == 0)))
     {
     FIg_erase(forms.part_operations_form_id,SIMILAR_MODE_GRP);
     FIg_erase(forms.part_operations_form_id, NEW_FILE_TXT);
     }
   else if (((ep_parttype) && ((strcmp(ep_parttype,"N") == 0) ||
                               (strcmp(ep_parttype,"n") == 0))) && 
            ((np_parttype) && ((strcmp(np_parttype,"N") != 0) &&
                               (strcmp(np_parttype,"n") != 0))))
     {
     FIg_set_state_off(forms.part_operations_form_id, SIMMODE_COPY_TGL);
     FIg_disable(forms.part_operations_form_id, SIMMODE_COPY_TGL);
     FIg_erase(PDU_form_id,SIMMODE_CHECKIN_TGL);
     PDU_simmode_copy = FALSE;
     PDU_simmode_checkin = FALSE;
     }

   return(PDM_S_SUCCESS); 
}

int PDUchange_file_permissions(file, mode)
char   *file;
mode_t  mode;
{
int    status = PDM_S_SUCCESS;
struct  stat file_status;
char    dir_entry_name[256];

  _pdm_debug("in the function PDUchange_file_permissions", 0);

  dir_entry_name[0] = '\0';
  strcpy(dir_entry_name, user->wrkst_cwd);
  strcat(dir_entry_name, "/");
  strcat(dir_entry_name, file);
  _pdm_debug("changing permissions on <%s>", dir_entry_name);
  status = stat(dir_entry_name, &file_status);
  if (status == 0)
     {
      /* Change file permissions to read write */
      status = PDUchmod(dir_entry_name, mode);
      _pdm_status("PDUchmod", status);
      if (status != PDM_S_SUCCESS)
        return(status);
      }
  else
    status = PDM_S_SUCCESS;

  return(status);
}

int PDUverify_part_data(form)
Form  form;
{

  int  status = PDM_S_SUCCESS;
  char  *msg = NULL;
  
  _pdm_debug("in the function PDUverify_part_data", 0);

  if (refresh->rev_catalog == NULL)
    {
    status = PDM_I_ENTER_CATALOG;
    msg = (char *) PDUtranslate_message(PDM_I_ENTER_CATALOG);
    FIg_set_text(form,FI_MSG_FIELD, msg);
    PDUmessage(PDM_I_ENTER_CATALOG , 's');
    return(status);
    }
  else if (strcmp(refresh->rev_catalog, "") == 0)
    {
    status = PDM_I_ENTER_CATALOG;
    msg = (char *) PDUtranslate_message(PDM_I_ENTER_CATALOG);
    FIg_set_text(form,FI_MSG_FIELD, msg);
    PDUmessage(PDM_I_ENTER_CATALOG , 's');
    return(status);
    }

  if (refresh->rev_partid == NULL)
    {
    status = PDM_I_ENTER_PART;
    msg = (char *) PDUtranslate_message(PDM_I_ENTER_PART);
    FIg_set_text(form,FI_MSG_FIELD, msg);
    PDUmessage(PDM_I_ENTER_PART , 's');
    return(status);
    }
  else if (strcmp(refresh->rev_partid, "")  == 0)
    {
    status = PDM_I_ENTER_PART;
    msg = (char *) PDUtranslate_message(PDM_I_ENTER_PART);
    FIg_set_text(form,FI_MSG_FIELD, msg);
    PDUmessage(PDM_I_ENTER_PART , 's');
    return(status);
    }

  if (refresh->rev_revision == NULL) 
    {
    status = PDM_I_ENTER_REVISION;
    msg = (char *) PDUtranslate_message(PDM_I_ENTER_REVISION);
    FIg_set_text(form,FI_MSG_FIELD, msg);
    PDUmessage(PDM_I_ENTER_REVISION , 's');
    return(status);
    }
  else if (strcmp(refresh->rev_revision, "")  == 0)
    {
    status = PDM_I_ENTER_REVISION;
    msg = (char *) PDUtranslate_message(PDM_I_ENTER_REVISION);
    FIg_set_text(form,FI_MSG_FIELD, msg);
    PDUmessage(PDM_I_ENTER_REVISION , 's');
    return(status);
    }

  return(status);
}

void PDUdisable_gadgets_for_add_part()
{
  FIg_disable(PDU_form_id,NP_PROJECT_BTN);
  FIg_disable(PDU_form_id,NP_CATALOG_BTN);
  FIg_disable(PDU_form_id,NP_PARTNUM_BTN);
  FIg_disable(PDU_form_id,NP_PARTTYPE_BTN);
  FIg_disable(PDU_form_id,NP_PROJECT_FLD);
  FIg_disable(PDU_form_id,NP_CATALOG_FLD);
  FIg_disable(PDU_form_id,NP_PARTNUM_FLD);
  FIg_disable(PDU_form_id,NP_REV_FLD);
  FIg_disable(PDU_form_id,NP_PARTTYPE_FLD);
  FIg_disable(PDU_form_id,NP_DESC_FLD);

  FIg_disable(PDU_form_id,ATTRIBUTE_VALUE_MCF);
  FIg_disable(PDU_form_id,FILE_INFO_MCF);

  if (similar_mode)
    {
    FIg_disable(PDU_form_id,EP_PROJECT_BTN);
    FIg_disable(PDU_form_id,EP_CATALOG_BTN);
    FIg_disable(PDU_form_id,EP_PARTNUM_BTN);
    FIg_disable(PDU_form_id,EP_REV_BTN);
    FIg_disable(PDU_form_id,EP_PROJECT_FLD);
    FIg_disable(PDU_form_id,EP_CATALOG_FLD);
    FIg_disable(PDU_form_id,EP_PARTNUM_FLD);
    FIg_disable(PDU_form_id,EP_REV_FLD);
    FIg_disable(PDU_form_id,EP_PARTTYPE_FLD);
    FIg_disable(PDU_form_id,EP_DESC_FLD);

    FIg_disable(PDU_form_id,SIMILAR_MODE_MCF);
    }
}

void PDUenable_gadgets_after_add_part()
{
  _pdm_debug("in the function PDUenable_gadgets_after_add_part", 0);
  FIg_enable(PDU_form_id,NP_PROJECT_BTN);
  FIg_enable(PDU_form_id,NP_CATALOG_BTN);
  FIg_enable(PDU_form_id,NP_PARTNUM_BTN);
  FIg_enable(PDU_form_id,NP_PARTTYPE_BTN);
  FIg_enable(PDU_form_id,NP_PROJECT_FLD);
  FIg_enable(PDU_form_id,NP_CATALOG_FLD);
  FIg_enable(PDU_form_id,NP_PARTNUM_FLD);
  FIg_enable(PDU_form_id,NP_REV_FLD);
  FIg_enable(PDU_form_id,NP_PARTTYPE_FLD);
  FIg_enable(PDU_form_id,NP_DESC_FLD);

  FIg_enable(PDU_form_id,ATTRIBUTE_VALUE_MCF);
  FIg_enable(PDU_form_id,FILE_INFO_MCF);

  if (similar_mode)
    {
    FIg_enable(PDU_form_id,EP_PROJECT_BTN);
    FIg_enable(PDU_form_id,EP_CATALOG_BTN);
    FIg_enable(PDU_form_id,EP_PARTNUM_BTN);
    FIg_enable(PDU_form_id,EP_REV_BTN);
    FIg_enable(PDU_form_id,EP_PROJECT_FLD);
    FIg_enable(PDU_form_id,EP_CATALOG_FLD);
    FIg_enable(PDU_form_id,EP_PARTNUM_FLD);
    FIg_enable(PDU_form_id,EP_REV_FLD);
    FIg_enable(PDU_form_id,EP_PARTTYPE_FLD);
    FIg_enable(PDU_form_id,EP_DESC_FLD);

    FIg_enable(PDU_form_id,SIMILAR_MODE_MCF);
    }
}

void PDUdisable_part_form_gadgets()
{

      _pdm_debug("in the function PDUdisable_part_form_gadgets", 0);

      FIg_disable(PDU_form_id,FI_HELP);
      FIg_disable(PDU_form_id,FI_CANCEL);
      FIg_disable(PDU_form_id,FI_RESET);

      /* existing part fields */
      if (!new_mode)
        {
        FIg_disable(PDU_form_id,EP_PROJECT_FLD);
        FIg_disable(PDU_form_id,EP_CATALOG_FLD);
        FIg_disable(PDU_form_id,EP_PARTNUM_FLD);
        FIg_disable(PDU_form_id,EP_REV_FLD);
        FIg_disable(PDU_form_id,EP_PARTTYPE_FLD);
        FIg_disable(PDU_form_id,EP_DESC_FLD);
        FIg_disable(PDU_form_id,EP_PROJECT_BTN);
        FIg_disable(PDU_form_id,EP_CATALOG_BTN);
        FIg_disable(PDU_form_id,EP_PARTNUM_BTN);
        FIg_disable(PDU_form_id,EP_REV_BTN);
        FIg_disable(PDU_form_id,EP_PARTTYPE_BTN);
        }

      if (new_mode || similar_mode)
        {
        /* new part fields */
        FIg_disable(PDU_form_id,NP_PROJECT_FLD);
        FIg_disable(PDU_form_id,NP_CATALOG_FLD);
        FIg_disable(PDU_form_id,NP_PARTNUM_FLD);
        FIg_disable(PDU_form_id,NP_REV_FLD);
        FIg_disable(PDU_form_id,NP_PARTTYPE_FLD);
        FIg_disable(PDU_form_id,NP_DESC_FLD);
        FIg_disable(PDU_form_id,NP_PROJECT_BTN);
        FIg_disable(PDU_form_id,NP_CATALOG_BTN);
        FIg_disable(PDU_form_id,NP_PARTNUM_BTN);
        FIg_disable(PDU_form_id,NP_PARTTYPE_BTN);
        }

      /* mode buttons */
      FIg_disable(PDU_form_id,NEW_MODE_BTN);
      FIg_disable(PDU_form_id,CHANGE_MODE_BTN);
      FIg_disable(PDU_form_id,SIMILAR_MODE_BTN);
      FIg_disable(PDU_form_id,REVIEW_MODE_BTN);

      /* command buttons */
      FIg_disable(PDU_form_id,ADD_BTN);
      FIg_disable(PDU_form_id,SEARCH_BTN);
      FIg_disable(PDU_form_id,CHANGE_BTN);
      FIg_disable(PDU_form_id,DELETE_BTN);
      FIg_disable(PDU_form_id,ADD_TO_PROJECT_BTN);
      FIg_disable(PDU_form_id,WHERE_USED_BTN);
      FIg_disable(PDU_form_id,FLAG_CANCELFLAG_BTN);
      FIg_disable(PDU_form_id,FLAG_OPERATIONS_GRP);
      FIg_disable(PDU_form_id,DELETE_FILES_BTN);
      FIg_disable(PDU_form_id,MOVE_STATE_BTN);

      if (review_mode)
        FIg_disable(PDU_form_id,FILE_INFO_MCF);
  
      if (change_mode)
        {
        FIg_disable(PDU_form_id,DELETE_FILES_TGL);
        FIg_disable(PDU_form_id,EXISTING_FILES_MCF);
        FIg_disable(PDU_form_id,NEW_FILES_MCF);
        }

      if (similar_mode)
        {
        FIg_disable(PDU_form_id,SIMILAR_MODE_MCF);
        FIg_disable(PDU_form_id,SIMMODE_COPY_TGL);
        }

      FIg_disable(PDU_form_id,ATTRIBUTE_VALUE_MCF);

}

void PDUenable_part_form_gadgets()
{

      _pdm_debug("in the function PDUenable_part_form_gadgets", 0);

      FIg_enable(PDU_form_id,FI_HELP);
      FIg_enable(PDU_form_id,FI_CANCEL);
      FIg_enable(PDU_form_id,FI_RESET);

      /* existing part fields */
      if (!new_mode)
        {
        FIg_enable(PDU_form_id,EP_PROJECT_FLD);
        FIg_enable(PDU_form_id,EP_CATALOG_FLD);
        FIg_enable(PDU_form_id,EP_PARTNUM_FLD);
        FIg_enable(PDU_form_id,EP_REV_FLD);
        FIg_enable(PDU_form_id,EP_PARTTYPE_FLD);
        FIg_enable(PDU_form_id,EP_DESC_FLD);
        FIg_enable(PDU_form_id,EP_PROJECT_BTN);
        FIg_enable(PDU_form_id,EP_CATALOG_BTN);
        FIg_enable(PDU_form_id,EP_PARTNUM_BTN);
        FIg_enable(PDU_form_id,EP_REV_BTN);
        FIg_enable(PDU_form_id,EP_PARTTYPE_BTN);
        }

      if (new_mode || similar_mode)
        {
        /* new part fields */
        FIg_enable(PDU_form_id,NP_PROJECT_FLD);
        FIg_enable(PDU_form_id,NP_CATALOG_FLD);
        FIg_enable(PDU_form_id,NP_PARTNUM_FLD);
        FIg_enable(PDU_form_id,NP_REV_FLD);
        FIg_enable(PDU_form_id,NP_PARTTYPE_FLD);
        FIg_enable(PDU_form_id,NP_DESC_FLD);
        FIg_enable(PDU_form_id,NP_PROJECT_BTN);
        FIg_enable(PDU_form_id,NP_CATALOG_BTN);
        FIg_enable(PDU_form_id,NP_PARTNUM_BTN);
        FIg_enable(PDU_form_id,NP_PARTTYPE_BTN);
        }

      /* mode buttons */
      FIg_enable(PDU_form_id,NEW_MODE_BTN);
      FIg_enable(PDU_form_id,CHANGE_MODE_BTN);
      FIg_enable(PDU_form_id,SIMILAR_MODE_BTN);
      FIg_enable(PDU_form_id,REVIEW_MODE_BTN);

      /* command buttons */
      FIg_enable(PDU_form_id,SEARCH_BTN);

      if (change_mode)
        {
        FIg_enable(PDU_form_id,CHANGE_BTN);
        FIg_enable(PDU_form_id,WHERE_USED_BTN);
        FIg_enable(PDU_form_id,FLAG_CANCELFLAG_BTN);
        FIg_enable(PDU_form_id,FLAG_OPERATIONS_GRP);
        FIg_enable(PDU_form_id,MOVE_STATE_BTN);

        if (refresh->rev_project && (strcmp(refresh->rev_project, "") != 0))
          FIg_enable(PDU_form_id,ADD_TO_PROJECT_BTN);

        FIg_display(PDU_form_id,DELETE_FILES_TGL);
        FIg_enable(PDU_form_id,DELETE_FILES_TGL);
        }

      if (similar_mode)
        FIg_enable(PDU_form_id,ADD_BTN);

      if (review_mode)
        {
        FIg_disable(PDU_form_id,DELETE_FILES_BTN);
        FIg_erase(PDU_form_id,DELETE_FILES_TGL);
        }
  
      /* file pallettes */
      if (review_mode)
        {
        FIg_enable(PDU_form_id,FILE_INFO_MCF);
        FIfld_set_mode(PDU_form_id,FILE_INFO_MCF, 0, FI_REVIEW);
        FIfld_set_mode(PDU_form_id,FILE_INFO_MCF, 1, FI_REVIEW);
        FIfld_set_mode(PDU_form_id,FILE_INFO_MCF, 2, FI_REVIEW);
        FIfld_set_mode(PDU_form_id,FILE_INFO_MCF, 3, FI_REVIEW);
        }

      if (change_mode)
        {
        FIg_enable(PDU_form_id,DELETE_FILES_TGL);
        FIg_enable(PDU_form_id,EXISTING_FILES_MCF);
        FIg_enable(PDU_form_id,NEW_FILES_MCF);
        }

      if (similar_mode)
        {
        FIg_enable(PDU_form_id,SIMILAR_MODE_MCF);
        FIg_enable(PDU_form_id,SIMMODE_COPY_TGL);
        }

      FIg_enable(PDU_form_id,ATTRIBUTE_VALUE_MCF);
}

void PDUdisable_gadgets_for_change_part()
{
  FIg_disable(PDU_form_id,EP_PROJECT_BTN);
  FIg_disable(PDU_form_id,EP_CATALOG_BTN);
  FIg_disable(PDU_form_id,EP_PARTNUM_BTN);
  FIg_disable(PDU_form_id,EP_PARTTYPE_BTN);
  FIg_disable(PDU_form_id,EP_REV_BTN);
  FIg_disable(PDU_form_id,EP_PROJECT_FLD);
  FIg_disable(PDU_form_id,EP_CATALOG_FLD);
  FIg_disable(PDU_form_id,EP_PARTNUM_FLD);
  FIg_disable(PDU_form_id,EP_REV_FLD);
  FIg_disable(PDU_form_id,EP_PARTTYPE_FLD);
  FIg_disable(PDU_form_id,EP_DESC_FLD);

  FIg_disable(PDU_form_id,ATTRIBUTE_VALUE_MCF);
  FIg_disable(PDU_form_id,EXISTING_FILES_MCF);
  FIg_disable(PDU_form_id,NEW_FILES_MCF);
  FIg_disable(PDU_form_id,DELETE_FILES_TGL);
  FIg_disable(PDU_form_id,MOVE_STATE_BTN);
  FIg_disable(PDU_form_id,STORAGE_AREA_BTN);

}

void PDUenable_gadgets_after_change_part()
{
  FIg_enable(PDU_form_id,EP_PROJECT_BTN);
  FIg_enable(PDU_form_id,EP_CATALOG_BTN);
  FIg_enable(PDU_form_id,EP_PARTNUM_BTN);
  FIg_enable(PDU_form_id,EP_PARTTYPE_BTN);
  FIg_enable(PDU_form_id,EP_REV_BTN);
  FIg_enable(PDU_form_id,EP_PROJECT_FLD);
  FIg_enable(PDU_form_id,EP_CATALOG_FLD);
  FIg_enable(PDU_form_id,EP_PARTNUM_FLD);
  FIg_enable(PDU_form_id,EP_REV_FLD);
  FIg_enable(PDU_form_id,EP_PARTTYPE_FLD);
  FIg_enable(PDU_form_id,EP_DESC_FLD);

  FIg_enable(PDU_form_id,ATTRIBUTE_VALUE_MCF);
  FIg_enable(PDU_form_id,EXISTING_FILES_MCF);
  FIg_enable(PDU_form_id,NEW_FILES_MCF);
  FIg_enable(PDU_form_id,DELETE_FILES_TGL);
  FIg_enable(PDU_form_id,MOVE_STATE_BTN);
  FIg_enable(PDU_form_id,STORAGE_AREA_BTN);

}


int PDUcheck_parttype_privileges(attr_bufr,
                                 parttype_update, parttype_read, parttype_write)
  MEMptr  attr_bufr;
  short *parttype_update;
  short *parttype_read;
  short *parttype_write;
{
  int   status = PDM_S_SUCCESS;
  int   i = 0;
  int   attr_row = 0;
  int   read_col = 0;
  int   write_col = 0;
  int   update_col = 0;
  int   n_name_col = 0;
  char  *read = NULL_STRING;
  char  *write = NULL_STRING;
  char  *update = NULL_STRING;
  char  **data_row;

  _pdm_debug("in the function PDUcheck_parttype_privileges", 0);

  status = MEMbuild_array(attr_bufr);
  _pdm_status("MEMbuild_array", status);
  if (status != MEM_S_SUCCESS)
    return(PDM_E_BUILD_BUFFER_ARRAY);

  PDUsetup_buffer(attr_bufr, ROW, &data_row);

  status = PDUget_buffer_col(attr_bufr, "n_update", &update_col);
  if (status != PDM_S_SUCCESS)
    {
    PDUmessage(status, 's');
    return(status);
    }

  status = PDUget_buffer_col(attr_bufr, "n_read", &read_col);
  if (status != PDM_S_SUCCESS)
    {
    PDUmessage(status, 's');
    return(status);
    }

  status = PDUget_buffer_col(attr_bufr, "n_write", &write_col);
  if (status != PDM_S_SUCCESS)
    {
    PDUmessage(status, 's');
    return(status);
    }

  status = PDUget_buffer_col(attr_bufr, "n_name", &n_name_col);
  if (status != PDM_S_SUCCESS)
    {
    PDUmessage(status, 's');
    return(status);
    }

  for (i = 0; i < attr_bufr->rows; i++)
     {
     if ((strcmp(data_row[(attr_bufr->columns * i) + n_name_col],
          "p_parttype") == 0))
        {
          _pdm_debug("checking for p_parttype",0);
          attr_row = -1;
          attr_row = PDUfind_attr_in_buffer(attr_bufr, "p_parttype");
          if (attr_row != -1)
            {
            PDUfill_in_string(&update,
                          data_row[(attr_bufr->columns * attr_row)+update_col]);
            _pdm_debug("update = <%s>", update);
            if (strcmp(update, "N") == 0)
              *parttype_update = FALSE;
            else
              *parttype_update = TRUE;
   
            PDUfill_in_string(&read,
                          data_row[(attr_bufr->columns * attr_row)+read_col]);
            _pdm_debug("read = <%s>", read);
            if (strcmp(read, "N") == 0)
              *parttype_read = FALSE;
            else
              *parttype_read = TRUE;
   
            PDUfill_in_string(&write,
                          data_row[(attr_bufr->columns * attr_row)+write_col]);
            _pdm_debug("write = <%s>", write);
            if (strcmp(write, "N") == 0)
              *parttype_write = FALSE;
            else
              *parttype_write = TRUE;
            }
          else
            {
            _pdm_debug("attribute p_parttype not found in attr_bufr", 0);
            if (new_mode || similar_mode)
              parttype_write = FALSE;
            if (change_mode)
              parttype_update = FALSE;
            if (review_mode)
              parttype_read = FALSE;
            }
          }
        }

  return(status);
}
