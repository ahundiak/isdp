#include "PDUerror.h"
#include "PDUsts_st.h"
#include "MEMerrordef.h"
#include "MEMstruct.h"
#include "part_gadgets.h"
#include "PDUforms.h"
#include "PDUproto.h"
#include "PDMproto.h"
#include "PDUfile_def.h"

#define TRUE  1

extern struct PDUrefresh  *refresh;
extern MEMptr PDU_ret_bufr;
extern MEMptr PDU_hold_bufr;
extern MEMptr PDU_ep_bufr;
extern Form PDU_form_id;
extern struct PDUforms forms;
extern int    change_mode;
extern int    new_mode;
extern int    similar_mode;
extern int    new_part_flag;
extern char  *np_catalog;
extern char  *ep_catalog;
extern char  *en_itemname;
extern char  *ep_rev;
extern MEMptr PDU_attr_bufr;

static int  status = PDM_S_SUCCESS;
extern int  string_len;

/* This function will call the PDMverify_project function to verify the 
   following:
              1) Whether a project name actually exists in the system.
              2) If the project is associated with a catalog that may
                 be entered.
*/

int PDUvalid_project(project,catalog)
    char   *project;
    char   *catalog;
    {

   _pdm_debug("Entering PDUvalid_project",0);

       string_len = strlen(project);

       if ( string_len == 0 )
          {
          return(PDM_E_PROJECT_FLD_BLANK);
          }

       if ( strlen(project) > 18 )
          {
          return(PDM_E_PROJECT_FLD_TOO_LONG);
          }

      status = PDMverify_project(project,catalog);

      return(status);
    }


int PDUvalid_catalog(project,catalog)
    char   *project;
    char   *catalog;
    {

   _pdm_debug("Entering PDUvalid_catalog",0);

    if (catalog == NULL)
      {
      return(PDM_E_CAT_FIELD_BLANK);
      }

    string_len = strlen(catalog);

    if ( string_len == 0 )
       {
       return(PDM_E_CAT_FIELD_BLANK);
       }

    if ( strlen(catalog) > 16 )
       {
       return(PDM_E_CATALOG_FIELD_TOO_LONG);
       }

   if ((PDU_form_id == forms.cat_name_form_id) ||
       (PDU_form_id == forms.local_files_form_id) ||
       (PDU_form_id == forms.part_operations_form_id))
      {
      if (isdigit (catalog[0]))
         return(PDM_E_INVALID_INPUT);
      }

   if (((PDU_form_id == forms.part_operations_form_id) && (PDU_form_id != 0)) &&
       ((new_mode == TRUE) || (similar_mode == TRUE)))
      {
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
      FIg_disable(PDU_form_id,FI_CANCEL);
      FIg_disable(PDU_form_id,FI_RESET);
      FIg_disable(PDU_form_id,FILE_INFO_MCF);
      FIg_disable(PDU_form_id,ATTRIBUTE_VALUE_MCF);
      FIg_disable(PDU_form_id,NEW_MODE_BTN);
      FIg_disable(PDU_form_id,CHANGE_MODE_BTN);
      FIg_disable(PDU_form_id,SIMILAR_MODE_BTN);
      FIg_disable(PDU_form_id,REVIEW_MODE_BTN);
      FIg_disable(PDU_form_id,ADD_BTN);
      FIg_disable(PDU_form_id,SEARCH_BTN);

      if (new_mode != TRUE)
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
         FIg_disable(PDU_form_id,SIMILAR_MODE_MCF);
         FIg_disable(PDU_form_id,SIMMODE_COPY_TGL);
         FIg_disable(PDU_form_id,SIMMODE_CHECKIN_TGL);
         }
      }

   status = PDMrverify_catalog(project,catalog);
   _pdm_status("PDMrverify_catalog",status);

   if (PDU_form_id == 0)
     return(status);
   if ((PDU_form_id == forms.part_operations_form_id) && 
       ((new_mode == TRUE) || (similar_mode == TRUE)))
      {
      FIg_enable(PDU_form_id,NP_PROJECT_FLD);
      FIg_enable(PDU_form_id,NP_CATALOG_FLD);
      FIg_enable(PDU_form_id,NP_PARTNUM_FLD);
      FIfld_set_mode(PDU_form_id,NP_PARTNUM_FLD, 0, FI_INSERT);
      FIg_display(PDU_form_id, NP_PARTNUM_FLD);
      FIg_enable(PDU_form_id,NP_REV_FLD);
      FIfld_set_mode(PDU_form_id,NP_REV_FLD, 0, FI_INSERT);
      FIg_display(PDU_form_id, NP_REV_FLD);
      FIg_enable(PDU_form_id,NP_PARTTYPE_FLD);
      FIg_enable(PDU_form_id,NP_DESC_FLD);
      FIfld_set_mode(PDU_form_id,NP_DESC_FLD, 0, FI_INSERT);
      FIg_display(PDU_form_id, NP_DESC_FLD);
      FIg_enable(PDU_form_id,NP_PROJECT_BTN);
      FIg_enable(PDU_form_id,NP_CATALOG_BTN);
      FIg_enable(PDU_form_id,NP_PARTNUM_BTN);
      FIg_enable(PDU_form_id,NP_PARTTYPE_BTN);
      FIg_enable(PDU_form_id,FI_CANCEL);
      FIg_enable(PDU_form_id,FI_RESET);
      FIg_enable(PDU_form_id,ATTRIBUTE_VALUE_MCF);
      FIg_enable(PDU_form_id,NEW_MODE_BTN);
      FIg_enable(PDU_form_id,CHANGE_MODE_BTN);
      FIg_enable(PDU_form_id,SIMILAR_MODE_BTN);
      FIg_enable(PDU_form_id,REVIEW_MODE_BTN);
      FIg_enable(PDU_form_id,ADD_BTN);
      FIg_enable(PDU_form_id,SEARCH_BTN);

      if (new_mode)
        {
        FIg_enable(PDU_form_id,FILE_INFO_MCF);
        FIfld_set_mode(PDU_form_id,FILE_INFO_MCF, 0, FI_INSERT);
        FIfld_set_mode(PDU_form_id,FILE_INFO_MCF, 1, FI_INSERT);
        FIfld_set_mode(PDU_form_id,FILE_INFO_MCF, 2, FI_INSERT);
        FIfld_set_mode(PDU_form_id,FILE_INFO_MCF, 3, FI_INSERT);
        FIg_display(PDU_form_id, FILE_INFO_MCF);
        }

      if (similar_mode)
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
         FIg_enable(PDU_form_id,SIMILAR_MODE_MCF);
         if (ep_catalog && en_itemname && ep_rev &&
            (strcmp(ep_catalog, "") != 0) &&
            (strcmp(en_itemname, "") != 0) &&
            (strcmp(ep_rev, "") != 0))
           FIg_enable(PDU_form_id,SIMMODE_COPY_TGL);
         else
           FIg_disable(PDU_form_id,SIMMODE_COPY_TGL);
         FIg_enable(PDU_form_id,SIMMODE_CHECKIN_TGL);
         }
      } 
      if (new_mode)
         FIg_display(PDU_form_id,FILE_INFO_MCF);
 
      if (similar_mode) 
         FIg_display(PDU_form_id,SIMILAR_MODE_MCF);

      return(status);
    }

int PDUvalid_partnum(catalog,partnum)
    char   *catalog;
    char   *partnum;
    {
    MEMptr        attr_bufr = NULL;
    MEMptr        data_bufr = NULL;
    char        * datatype = NULL;
    char        * msg = NULL;
    char       ** data1_row;
    char       ** data1_col;
    char       ** data1_format;
    char       ** data2_row;
    char       ** data2_col;
    char       ** data2_format;
    int           n_name_col;
    int           n_datatype_col;
    int           i;
    int           length;
    int           char_index;

   _pdm_debug("Entering PDUvalid_partnum",0);

    status = PDM_S_SUCCESS;

    string_len = strlen(partnum);
    if ( string_len == 0 )
       {
       return(PDM_E_PART_FIELD_BLANK);
       }

    _pdm_debug("parsing through string", 0);
    for (char_index = 0; char_index < string_len; ++char_index)
        {
        if ((partnum[char_index] == '!') ||
            (partnum[char_index] == '*') ||
            (partnum[char_index] == '?') ||
            (partnum[char_index] == ',') ||
            (partnum[char_index] == ':'))
           {
           msg = (char *)PDUtranslate_message(PDM_E_SPEC_CHAR_IN_FIELD);
           FIg_set_text(PDU_form_id,FI_MSG_FIELD,msg);
           return(PDM_E_INVALID_CHAR_IN_PART);
           }
        }

    if ((PDU_form_id == forms.part_operations_form_id) && (new_mode == TRUE))
       {
          status = PDUsetup_buffer_list(PDU_hold_bufr, 1, 0, &data1_row,
                                        &data1_col,&data1_format,&attr_bufr);
          if (status != PDM_S_SUCCESS)
          return(status);

          status = PDUsetup_buffer_list(PDU_hold_bufr, 2, 0, &data2_row,
                                        &data2_col,&data2_format,&data_bufr);
          if (status != PDM_S_SUCCESS)
             return(status);

       status = PDUget_col_number(attr_bufr,"n_name",data1_col, &n_name_col);

       status = PDUget_col_number(attr_bufr,"n_datatype",data1_col,
                                  &n_datatype_col);

       for (i = 0; i < attr_bufr->rows; ++i)
          {
          if (strcmp(data1_row[(attr_bufr->columns * i) + n_name_col],
              "n_itemname") == 0)
             {
             datatype = data1_row[(attr_bufr->columns * i) + n_datatype_col];
             break;
             }
          }

       status = PDUvalidate_value(partnum,datatype);
       _pdm_status("PDUvalidate_value",status);

       if (status == PDM_E_IDENTIFIER_TOO_LONG)
          {
          sscanf(datatype,"char(%d)",&length);
          msg = (char *)PDUtranslate_message(PDM_E_PARTNUM_LENGTH);
          FIg_set_text(forms.part_operations_form_id,FI_MSG_FIELD,msg);
          }
       }

   if ((PDU_form_id == forms.part_operations_form_id) &&
       (change_mode == TRUE))
      {
      FIg_disable(PDU_form_id,FI_CANCEL);
      FIg_disable(PDU_form_id,FI_RESET);
      FIg_disable(PDU_form_id,DELETE_FILES_TGL);
      }

   if ((status == PDM_S_SUCCESS) && (new_mode != TRUE) && 
       (new_part_flag != TRUE))
      {
      status = PDMverify_partnum(catalog,partnum);
      _pdm_status("PDMverify_partnum",status);
      }

   if ((PDU_form_id == forms.part_operations_form_id) &&
       (change_mode == TRUE))
      {
      FIg_enable(PDU_form_id,FI_CANCEL);
      FIg_enable(PDU_form_id,FI_RESET);
      }

   if ((PDU_form_id == forms.part_operations_form_id) &&
       (change_mode == TRUE) && (status == PDM_S_SUCCESS))
      {
      FIg_enable(PDU_form_id,DELETE_FILES_TGL);
      }

   return(status);
   }

int PDUvalid_rev(rev)
    char   *rev;
    {
    MEMptr        attr_bufr = NULL;
    MEMptr        data_bufr = NULL;
    char        * datatype = NULL;
    char        * msg = NULL;
    char       ** data1_row;
    char       ** data1_col;
    char       ** data1_format;
    char       ** data2_row;
    char       ** data2_col;
    char       ** data2_format;
    int           n_name_col;
    int           n_datatype_col;
    int           i;
    int           length;
    int           char_index;
    string_len = strlen(rev);

    status = PDM_S_SUCCESS;

    _pdm_debug("Entering PDUvalid_rev",0);

    for (char_index = 0; char_index < string_len; ++char_index)
        {
        if ((rev[char_index] == '!') || (rev[char_index] == '*') ||
            (rev[char_index] == '?') || (rev[char_index] == ',') ||
            (rev[char_index] == ':'))
           {
           msg = (char *)PDUtranslate_message(PDM_E_SPEC_CHAR_IN_FIELD);
           FIg_set_text(PDU_form_id,FI_MSG_FIELD,msg);
           status = PDM_E_INVALID_CHAR_IN_REV;
           PDUmessage(status, 's');
           return(PDM_E_INVALID_CHAR_IN_REV);
           }
        }

    if ((new_mode == TRUE) || (similar_mode == TRUE))
    {
/*
    status = PDUsetup_buffer_list(PDU_ret_bufr, 1, 0, &data1_row,
                                  &data1_col,&data1_format,&attr_bufr);
    if (status != PDM_S_SUCCESS)
       return(status);

    status = PDUsetup_buffer_list(PDU_ret_bufr, 2, 0, &data2_row,
                                  &data2_col,&data2_format,&data_bufr);
    if (status != PDM_S_SUCCESS)
       return(status);
*/

    MEMbuild_array(PDU_attr_bufr);
    PDUsetup_buffer(PDU_attr_bufr, ROW, &data1_row);

    MEMprint_buffer("PDU_attr_bufr", PDU_attr_bufr, PDU_DEBUG_FILE);

    status = PDUget_buffer_col(PDU_attr_bufr,"n_name", &n_name_col);

    status = PDUget_buffer_col(PDU_attr_bufr,"n_datatype", &n_datatype_col);

    _pdm_debug("datatype_col = %d", n_datatype_col);

    for (i = 0; i < PDU_attr_bufr->rows; ++i)
        {
        if (strcmp(data1_row[(PDU_attr_bufr->columns * i) + n_name_col],
           "n_itemrev") == 0)
           {
           PDUfill_in_string(&datatype, data1_row[(PDU_attr_bufr->columns * i) + n_datatype_col]);
           _pdm_debug("datatype = <%s>", datatype);
           break;
           }
        }

   if (!datatype)
     datatype = NULL_STRING;

   status = PDUvalidate_value(rev,datatype);
   _pdm_status("PDUvalidate_value",status);

   if (status == PDM_E_IDENTIFIER_TOO_LONG)
      {
      sscanf(datatype,"char(%d)",&length);
      msg = (char *)PDUtranslate_message(PDM_E_REV_LENGTH);
      FIg_set_text(PDU_form_id,FI_MSG_FIELD,msg);
      }
   }
   return(status);
   }

int PDUvalid_desc(desc)
    char   *desc;
    {
    MEMptr        attr_bufr = NULL;
    MEMptr        data_bufr = NULL;
    char        * datatype = NULL;
    char        * msg = NULL;
    char       ** data1_row;
    char       ** data1_col;
    char       ** data1_format;
    char       ** data2_row;
    char       ** data2_col;
    char       ** data2_format;
    int           n_name_col;
    int           n_datatype_col;
    int           i;
    int           length;

   _pdm_debug("Entering PDUvalid_desc",0);

    if ((new_mode == TRUE) || (similar_mode == TRUE))
    {
    status = PDUsetup_buffer_list(PDU_hold_bufr, 1, 0, &data1_row,
                                  &data1_col,&data1_format,&attr_bufr);
    if (status != PDM_S_SUCCESS)
       return(status);

    status = PDUsetup_buffer_list(PDU_hold_bufr, 2, 0, &data2_row,
                                  &data2_col,&data2_format,&data_bufr);
    if (status != PDM_S_SUCCESS)
       return(status);
    }
    else if (change_mode == TRUE)  
    {
    status = PDUsetup_buffer_list(PDU_ep_bufr, 1, 0, &data1_row,
                                  &data1_col,&data1_format,&attr_bufr);
    if (status != PDM_S_SUCCESS)
       return(status);

    status = PDUsetup_buffer_list(PDU_ep_bufr, 2, 0, &data2_row,
                                  &data2_col,&data2_format,&data_bufr);
    if (status != PDM_S_SUCCESS)
       return(status);
    }

    if ((new_mode == TRUE) || (similar_mode == TRUE) || (change_mode == TRUE))
    {
    status = PDUget_col_number(attr_bufr,"n_name",data1_col, &n_name_col);

    status = PDUget_col_number(attr_bufr,"n_datatype",data1_col,
                               &n_datatype_col);

    for (i = 0; i < attr_bufr->rows; ++i)
        {
        if (strcmp(data1_row[(attr_bufr->columns * i) + n_name_col],
           "n_itemdesc") == 0)
           {
           datatype = data1_row[(attr_bufr->columns * i) + n_datatype_col];
           break;
           }
        }

   if (!datatype)
     PDUfill_in_string(&datatype, "char(40)");
   else if (strcmp(datatype, "") == 0)
     PDUfill_in_string(&datatype, "char(40)");

   status = PDUvalidate_value(desc,datatype);
   _pdm_status("PDUvalidate_value",status);

   if (status == PDM_E_IDENTIFIER_TOO_LONG)
      {
      sscanf(datatype,"char(%d)",&length);
      msg = (char *)PDUtranslate_message(PDM_E_DESC_LENGTH);
      FIg_set_text(PDU_form_id,FI_MSG_FIELD,msg);
      }

   }
   return(status);
   }

int PDUcheck_partnum(catalog,partnum,revision)
 
   char  *catalog;
   char  *partnum;
   char  *revision;

{

   _pdm_debug("Entering PDUcheck_partnum",0);

       string_len = strlen(partnum);

       if ( string_len == 0 )
          {
          return(PDM_E_PART_FIELD_BLANK);
          }

       status = PDMcheck_partnum(catalog,partnum,revision);

       return(status);
}

int PDUget_part_from_desc(catalog,description)

   char  *catalog;
   char  *description;

{

   _pdm_debug("Entering PDUget_part_from_desc",0);

       string_len = strlen(catalog);

       if ( string_len == 0 )
          {
          return(PDM_E_CAT_FIELD_BLANK);
          }

       status = PDMget_part_from_desc(catalog,description);

       return(status);
}

