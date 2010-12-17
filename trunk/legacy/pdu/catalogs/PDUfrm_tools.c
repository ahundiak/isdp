#include        <stdio.h>
#include        <FI.h>
#include	<PDUstr.h>
#include	<PDUuser.h>
#include	<PDUstorage.h>
#include	<PDUerror.h>
#include	<PDMtypes.h>
#include        <PDUforms.h>
#include        <PDUprompt.h>
#include        <PDUcommand.h>
#include        <PDUfile_def.h>
#include        <PDUparamdef.h>
#include        <part_gadgets.h>
#include	<MEMerrordef.h>
#include	<PDMmessage.h>
#include	<PDUproto.h>
#include	<PDMproto.h>

extern int PDM_debug_on;
extern int PDU_view;
extern MEMptr PDU_save_attr_bufr;
extern MEMptr PDU_cat_func_bufr;
extern char *PDU_attr_name;
extern char *PDU_template_catalog;
extern char *PDU_cat_description;
extern char *PDU_dynamic_table;
extern int PDU_parm_cat;
extern int PDU_command;
extern struct PDUforms forms;
extern struct PDUrefresh *refresh;

int PDUget_catalog_buffers(command)

int command;
   {
   int status;
   int i;
   char order_num[10];
   MEMptr loc_attr = NULL;
   MEMptr loc_data = NULL;
   MEMptr loc_list = NULL;
   MEMptr cat_attr = NULL;
   MEMptr cat_data = NULL;
   MEMptr cat_list = NULL;
   MEMptr new_cat_attr = NULL;
   MEMptr new_cat_data = NULL;
   MEMptr new_cat_list = NULL;
   MEMptr dyn_attr = NULL; 
   MEMptr dyn_data = NULL; 
   MEMptr dyn_list = NULL; 
   MEMptr acl_list = NULL;
   char *dyn_table = NULL;
   extern char *PDU_loc_attr;
   extern char *PDU_loc_data;
   extern char *PDU_loc_list;
   extern char *PDU_cat_atr;
   extern char *PDU_cat_data;
   extern char *PDU_cat_list;
   extern char *PDU_dyn_attr;
   extern char *PDU_dyn_data;
   extern char *PDU_dyn_list;
   extern struct PDUstorage *storage;
   extern struct PDUuser *user;

  _pdm_debug("command = <%d>", (char *)command);
   if ((PDU_command == PDC_M_CREATE_LIKE_CATALOG) && (PDU_view))
     {
     PDU_command = PDC_M_CREATE_CATALOG;
     }

   if (PDU_command == PDC_M_CREATE_CATALOG)
     {
      /* get the set of default attributes needed in every catalog */
      if (!PDU_view)
      {
      status = PDMget_table_attributes(ADD_TABLE, PDM_CATALOG, 
			    "pdmcatalog", &cat_attr, &cat_data,
			     &cat_list);
      _pdm_status ("PDMget_table_attributes", status );

      if (status != PDM_S_SUCCESS)
        return(status);
    if (PDM_debug_on)
      MEMprint_buffer("cat_attr", cat_attr, PDU_DEBUG_FILE);
      }
     else
       {
       _pdm_debug("user wants to create a catalog from a view", 0);
       status = PDMprepare_view_catalog_creation(&loc_data, &acl_list, 
                                                 &cat_attr, &cat_data, 
                                                 &cat_list);
       _pdm_status("PDMprepare_view_catalog_creation", status);

       if (status != PDM_S_SUCCESS)
         return(status);

       _pdm_debug("refresh->rev_catalog = <%s>", refresh->rev_catalog);
       status = PDMpopulate_attribute_info(refresh->rev_catalog, cat_attr, 
                                           &cat_data, cat_list);
       _pdm_status("PDMpopulate_attribute_info", status);
       _pdm_debug("refresh->rev_catalog = <%s>", refresh->rev_catalog);

       if (status != PDM_S_SUCCESS)
         return(status);
       }

      if (PDU_parm_cat)
        {
        status = PDUload_parametric_attributes(&cat_attr, &cat_data, &dyn_attr,
                                               &dyn_data, MACRO_ATTR_MCF);
        _pdm_status("PDUload_parametric_attributes", status);

        status = PDUload_parametric_attributes(&cat_attr, &cat_data, &dyn_attr,
                                               &dyn_data, MACRO_DYN_MCF);
        _pdm_status("DUload_parametric_attributes", status);

         status = PDUload_macro_parameters();
         _pdm_status("PDUload_macro_parameters", status);

         FIf_delete(forms.parametric_catalog_form_id);
         }

     if ((PDU_dynamic_table) && (strcmp(PDU_dynamic_table, "") != 0))
       {
       free(PDU_dynamic_table);
       PDU_dynamic_table = NULL;
       }
      
       PDU_dynamic_table = (char *)malloc(strlen(refresh->rev_catalog) + 5);
       memset(PDU_dynamic_table, NULL, (strlen(refresh->rev_catalog) + 5));
       sprintf(PDU_dynamic_table, "%s%s", "y_", refresh->rev_catalog);

      /* set buffers to global variables for catalog attribute form */
      PDU_loc_data = (char *)loc_data;
      PDU_cat_atr = (char *)cat_attr;
      PDU_cat_data = (char *)cat_data;
      PDU_cat_list = (char *)cat_list;
      PDU_dyn_attr = (char *)dyn_attr;
      PDU_dyn_data = (char *)dyn_data;
      }
    else if (PDU_command == PDC_M_CREATE_LIKE_CATALOG)
      {
      /* get the attributes in the catalog */
      status = PDMget_table_data(QUERY_DATA, PDM_CATALOG,
				   PDU_template_catalog, "", "", &cat_attr,
				   &cat_data, &cat_list);
      _pdm_status("PDMget_table_attributes", status);
	            
      if ( status != PDM_S_SUCCESS )
        return(status);

    /* addded for NFM3.0 */
    status = PDMget_table_attributes(ADD_TABLE, PDM_CATALOG, "pdmcatalog",
                                     &new_cat_attr, &new_cat_data,
                                     &new_cat_list);
    _pdm_status("PDMget_table_attributes(copy/change)", status);

    if (status != PDM_S_SUCCESS)
      return(status);

    /* call function to add user defined attributes to new_cat_attr */
    status = PDUmerge_copycat_buffers(&cat_attr, new_cat_attr);
    _pdm_status("PDUmerge_copycat_buffers", status);

    if (status != PDM_S_SUCCESS)
      return(status);

    if (PDM_debug_on)
      MEMprint_buffer("cat_attr", cat_attr, PDU_DEBUG_FILE);

    if (new_cat_attr)
      MEMclose(&new_cat_attr);
    if (new_cat_data)
      MEMclose(&new_cat_data);
    if (new_cat_list)
      MEMclose(&new_cat_list);

     /* get the attributes in the catalog */
     if ((PDU_dynamic_table) && (strcmp(PDU_dynamic_table, "") != 0))
       {
       free(PDU_dynamic_table);
       PDU_dynamic_table = NULL;
       }
      
     PDUload_exec_structure("", PDU_template_catalog, "", "","","","",0, 0);
     status = PDMdyntable_for_catalog(&dyn_table);
     _pdm_status("PDMdyntable_for_catalog", status);

     if ((status != PDM_S_SUCCESS) || (dyn_table == NULL))
       {
       PDU_dynamic_table = (char *)malloc(strlen(refresh->rev_catalog) + 5);
       memset(PDU_dynamic_table, NULL, (strlen(refresh->rev_catalog) + 5));
       sprintf(PDU_dynamic_table, "%s%s", "y_", refresh->rev_catalog);
       }
     else if (strcmp(dyn_table, "") == 0)
       {
       PDU_dynamic_table = (char *)malloc(strlen(refresh->rev_catalog) + 5);
       memset(PDU_dynamic_table, NULL, (strlen(refresh->rev_catalog) + 5));
       sprintf(PDU_dynamic_table, "%s%s", "y_", refresh->rev_catalog);
       }
     else
       {
       PDU_dynamic_table = (char *)malloc(strlen(refresh->rev_catalog) + 5);
       memset(PDU_dynamic_table, NULL, (strlen(refresh->rev_catalog) + 5));
       sprintf(PDU_dynamic_table, "%s%s", "y_", refresh->rev_catalog);
       }

     status = PDMget_dynamic_attributes(PDU_template_catalog, &dyn_attr,
				     &dyn_data, &dyn_list);
     _pdm_status("PDMget_table_attributes", status);
	            
      if ((status != PDM_S_SUCCESS) || (!(dyn_attr)))
        {
        MEMclose(&dyn_attr);
        dyn_attr = NULL;
        _pdm_debug("no dynamic attrs were defined for the source catalog", 0);
        }

      if ((PDM_debug_on) && (dyn_attr))
        MEMprint_buffer("source catalog dynamic attributes", dyn_attr, PDU_DEBUG_FILE);

      if (PDU_parm_cat)
        {
        status = PDUload_parametric_attributes(&cat_attr, &cat_data, &dyn_attr,
                                               &dyn_data, MACRO_ATTR_MCF);
        _pdm_status("PDUload_parametric_attributes", status);

        status = PDUload_parametric_attributes(&cat_attr, &cat_data, &dyn_attr,
                                               &dyn_data, MACRO_DYN_MCF);
        _pdm_status("PDUload_parametric_attributes", status);

         status = PDUload_macro_parameters();
         _pdm_status("PDUload_macro_parameters", 0);

         FIf_delete(forms.parametric_catalog_form_id);
         }

    PDUmessage(PDS_M_FUNCTION_FILES, 's');
    status = PDMquery_attribute_functions(PDU_template_catalog,
                               &PDU_cat_func_bufr);
   _pdm_status("PDMquery_attribute_functions",status);
    PDUmessage(status, 's');

   if (PDU_cat_func_bufr == NULL)
     _pdm_debug("no functions for this catalog", 0);
   else if (PDU_cat_func_bufr->rows ==0)
      {
      MEMclose(&PDU_cat_func_bufr);
      PDU_cat_func_bufr = NULL;
      }
      /* set buffers to global variables for catalog attribute form */
      PDU_cat_atr = (char *)cat_attr;
      PDU_cat_data = (char *)cat_data;
      PDU_cat_list = (char *)cat_list;
      PDU_dyn_attr = (char *)dyn_attr;
      PDU_dyn_data = (char *)dyn_data;
      PDU_dyn_list = (char *)dyn_list;
     }
   else
     {
     /* get the attributes in the catalog */
     if ((!PDU_view) && (!PDU_parm_cat))
     {
     status = PDMget_table_attributes(MODIFY_TABLE, PDM_CATALOG,
				     refresh->rev_catalog, &cat_attr,
				     &cat_data, &cat_list);
     _pdm_status("PDMget_table_attributes", status);
	            
     if ( status != PDM_S_SUCCESS )
         return(status);

     if ((PDU_dynamic_table) && (strcmp(PDU_dynamic_table, "") != 0))
       {
       free(PDU_dynamic_table);
       PDU_dynamic_table = NULL;
       }
      
     PDUload_exec_structure("", refresh->rev_catalog, "", "","","","",0, 0);
     status = PDMdyntable_for_catalog(&dyn_table);
     _pdm_status("PDMdyntable_for_catalog", status);

     if ((status != PDM_S_SUCCESS) || (dyn_table == NULL))
       {
       PDU_dynamic_table = (char *)malloc(strlen(refresh->rev_catalog) + 5);
       memset(PDU_dynamic_table, NULL, (strlen(refresh->rev_catalog) + 5));
       sprintf(PDU_dynamic_table, "%s%s", "y_", refresh->rev_catalog);
       }
     else if (strcmp(dyn_table, "") == 0)
       {
       PDU_dynamic_table = (char *)malloc(strlen(refresh->rev_catalog) + 5);
       memset(PDU_dynamic_table, NULL, (strlen(refresh->rev_catalog) + 5));
       sprintf(PDU_dynamic_table, "%s%s", "y_", refresh->rev_catalog);
       }
     else
       {
       _pdm_debug("dyn_table = <%s>", dyn_table);
       PDUfill_in_string(&PDU_dynamic_table, dyn_table);
       }

     /* get the attributes in the catalog */
     status = PDMget_dynamic_attributes(refresh->rev_catalog, &dyn_attr,
				     &dyn_data, &dyn_list);
     _pdm_status("PDMget_table_attributes", status);
	            
     if ((status != PDM_S_SUCCESS) || (!(dyn_attr)))
       {
       MEMclose(&dyn_attr);
       dyn_attr = NULL;
       _pdm_debug("no dynamic attrs were defined for the source catalog",                         0);
        }
     }
     else if (PDU_view)
     {
     PDUmessage(PDS_M_GET_TABLE_ATTR, 's');
     status = PDMprepare_change_view_catalog(user->user_id, 
                                                   refresh->rev_catalog,
                                                   &loc_attr, &loc_data, 
                                                   &loc_list, &cat_attr, 
                                                   &cat_data, &cat_list, 
                                                   &dyn_table, &dyn_attr, 
                                                   &dyn_data, &dyn_list);
     _pdm_status("PDMprepare_change_view_catalog", status);

     if (PDM_debug_on) 
        MEMprint_buffer("catalog attributes",
                         cat_attr,PDU_DEBUG_FILE);

     if (dyn_attr)
       MEMclose(&dyn_attr);
     if (dyn_data)
       MEMclose(&dyn_data);
     if (dyn_list)
       MEMclose(&dyn_list);
     if ((PDU_dynamic_table) && (strcmp(PDU_dynamic_table, "") != 0))
       {
       free(PDU_dynamic_table);
       PDU_dynamic_table = NULL;
       }
      
     PDUload_exec_structure("", refresh->rev_catalog, "", "","","","",0, 0);
     status = PDMdyntable_for_catalog(&dyn_table);
     _pdm_status("PDMdyntable_for_catalog", status);

     if ((status != PDM_S_SUCCESS) || (dyn_table == NULL))
       {
       PDU_dynamic_table = (char *)malloc(strlen(refresh->rev_catalog) + 5);
       memset(PDU_dynamic_table, NULL, (strlen(refresh->rev_catalog) + 5));
       sprintf(PDU_dynamic_table, "%s%s", "y_", refresh->rev_catalog);
       }
     else if (strcmp(dyn_table, "") == 0)
       {
       PDU_dynamic_table = (char *)malloc(strlen(refresh->rev_catalog) + 5);
       memset(PDU_dynamic_table, NULL, (strlen(refresh->rev_catalog) + 5));
       sprintf(PDU_dynamic_table, "%s%s", "y_", refresh->rev_catalog);
       }
     else
       {
       _pdm_debug("dyn_table = <%s>", dyn_table);
       PDUfill_in_string(&PDU_dynamic_table, dyn_table);
       }

     status = PDMget_dynamic_attributes(refresh->rev_catalog, &dyn_attr,
				     &dyn_data, &dyn_list);
     _pdm_status("PDMget_table_attributes", status);
	            
     if (!(dyn_attr))
       {
       MEMclose(&dyn_attr);
       dyn_attr = NULL;
       _pdm_debug("no dynamic attrs were defined for the source catalog",                         0);
       status = PDM_S_SUCCESS;
        }
    status = PDUmodify_parametric_synonym(&cat_attr, &dyn_attr);
    _pdm_status("PDUmodify_parametric_synonym", status);
     }
     else
     {
     PDUmessage(PDS_M_GET_TABLE_ATTR, 's');
     status = PDMprepare_change_parametric_catalog(user->user_id, 
                                                   refresh->rev_catalog,
                                                   &loc_attr, &loc_data, 
                                                   &loc_list, &cat_attr, 
                                                   &cat_data, &cat_list, 
                                                   &dyn_table, &dyn_attr, 
                                                   &dyn_data, &dyn_list);
     _pdm_status("PDMprepare_change_parametric_catalog", status);

     if (PDM_debug_on) 
        MEMprint_buffer("catalog attributes",
                         cat_attr,PDU_DEBUG_FILE);

     if (dyn_attr)
       MEMclose(&dyn_attr);
     if (dyn_data)
       MEMclose(&dyn_data);
     if (dyn_list)
       MEMclose(&dyn_list);
     if ((PDU_dynamic_table) && (strcmp(PDU_dynamic_table, "") != 0))
       {
       free(PDU_dynamic_table);
       PDU_dynamic_table = NULL;
       }
      
     PDUload_exec_structure("", refresh->rev_catalog, "", "","","","",0, 0);
     status = PDMdyntable_for_catalog(&dyn_table);
     _pdm_status("PDMdyntable_for_catalog", status);

     if ((status != PDM_S_SUCCESS) || (dyn_table == NULL))
       {
       PDU_dynamic_table = (char *)malloc(strlen(refresh->rev_catalog) + 5);
       memset(PDU_dynamic_table, NULL, (strlen(refresh->rev_catalog) + 5));
       sprintf(PDU_dynamic_table, "%s%s", "y_", refresh->rev_catalog);
       }
     else if (strcmp(dyn_table, "") == 0)
       {
       PDU_dynamic_table = (char *)malloc(strlen(refresh->rev_catalog) + 5);
       memset(PDU_dynamic_table, NULL, (strlen(refresh->rev_catalog) + 5));
       sprintf(PDU_dynamic_table, "%s%s", "y_", refresh->rev_catalog);
       }
     else
       {
       _pdm_debug("dyn_table = <%s>", dyn_table);
       PDUfill_in_string(&PDU_dynamic_table, dyn_table);
       }

     status = PDMget_dynamic_attributes(refresh->rev_catalog, &dyn_attr,
				     &dyn_data, &dyn_list);
     _pdm_status("PDMget_table_attributes", status);
	            
     if (!(dyn_attr))
       {
       MEMclose(&dyn_attr);
       dyn_attr = NULL;
       _pdm_debug("no dynamic attrs were defined for the source catalog",                         0);
       status = PDM_S_SUCCESS;
        }
    status = PDUmodify_parametric_synonym(&cat_attr, &dyn_attr);
    _pdm_status("PDUmodify_parametric_synonym", status);

    status = MEMbuild_array(cat_attr);
    _pdm_status("MEMbuild_array", status);

    if (status != MEM_S_SUCCESS)
      return(PDM_E_BUILD_BUFFER_ARRAY);

    for (i = 0; i < cat_attr->rows; i++)
     {
     sprintf(order_num, "%d", (i + 1));
     status = MEMwrite_data(cat_attr, order_num, (i + 1), 
                            (PDU_NFM_MOD_OFFSET + PDU_NFM_SEQNO_COL + 1));
     _pdm_status("MEMwrite_data", status);
     }

    }
    PDUmessage(PDS_M_FUNCTION_FILES, 's');
    status = PDMquery_attribute_functions(refresh->rev_catalog,
                               &PDU_cat_func_bufr);
   _pdm_status("PDMquery_attribute_functions",status);
    PDUmessage(status, 's');

   if (PDU_cat_func_bufr == NULL)
     _pdm_debug("no functions for this catalog", 0);
   else if (PDU_cat_func_bufr->rows ==0)
      {
      MEMclose(&PDU_cat_func_bufr);
      PDU_cat_func_bufr = NULL;
      }

     status = MEMsplit_copy_buffer(cat_attr, &PDU_save_attr_bufr, 0);
     _pdm_status("MEMsplit_copy_buffer_no", status);

     if ((PDM_debug_on) && (dyn_attr))
        MEMprint_buffer("source catalog dynamic attributes",
                         dyn_attr,PDU_DEBUG_FILE);

      /* set buffers to global variables for catalog attribute form */
      PDU_loc_attr = (char *)loc_attr;
      PDU_loc_data = (char *)loc_data;
      PDU_loc_list = (char *)loc_list;
      PDU_cat_atr = (char *)cat_attr;
      PDU_cat_data = (char *)cat_data;
      PDU_cat_list = (char *)cat_list;
      PDU_dyn_attr = (char *)dyn_attr;
      PDU_dyn_data = (char *)dyn_data;
      PDU_dyn_list = (char *)dyn_list;
      }
  return(PDM_S_SUCCESS);
  }

int PDUsort_by_order(attr_bufr, data_bufr, sort_attr, sort_data)

MEMptr attr_bufr;
MEMptr data_bufr;
MEMptr *sort_attr;
MEMptr *sort_data;

  {
  int status;
  int i;
  int num_rows;
  int char_index;
  int j,k;
  int sort_no;
  char **attr_data = NULL;
  char **data_data = NULL;
  char **data_col = NULL;
  char **sort_col = NULL;
  char  *row = NULL;

  _pdm_debug("In the function PDUsort_by_order", 0);

  /* format sorted buffer */
  status = PDUcreate_dynamic_attr_buffr(sort_attr);
  _pdm_status("PDUcreate_dynamic_attr_buffr", status);

  if (status != PDM_S_SUCCESS)
    return(status);

  status = MEMbuild_array(attr_bufr);
  _pdm_status("MEMbuild_array", status);

  if (status != MEM_S_SUCCESS)
    {
    MEMclose(sort_attr);
    return(PDM_E_BUILD_BUFFER_ARRAY);
    }
  
  attr_data = (char **) attr_bufr->data_ptr;

  /* malloc row */
  row = (char *)malloc((*sort_attr)->row_size);

  /* set num_rows to mark rows found */
  num_rows = 0;

  for (k = 0; num_rows < attr_bufr->rows; k++)
  {
  for (i = 0; i < attr_bufr->rows; i ++)
    {
    /* convert order no to integer */
    sscanf(attr_data[(attr_bufr->columns * i) + PDU_NFM_SEQNO_COL], "%d", 
           &sort_no);
    if (sort_no == k)
      {
      memset(row, NULL, (*sort_attr)->row_size);
      /* write data from row in attr_bufr to sort_attr */
      char_index = 0;
      for (j = 0; j < attr_bufr->columns; j++)
         {
         if ((strlen(attr_data[(attr_bufr->columns * i) + j])) && 
            (attr_data[(attr_bufr->columns * i) + j]))
           PDUadd_buffer_string(row, &char_index, attr_data[(attr_bufr->columns
                                * i) + j]);
         else
           row[char_index++] = '\1';
         }
      status = MEMwrite(*sort_attr, row);
      _pdm_status("MEMwrite", status);

      if (status != MEM_S_SUCCESS)
        {
        if (*sort_attr)
          MEMclose(sort_attr);
        free(row);
        return(PDM_E_WRITE_BUFFER);
        }
      /* increment num_rows */
      num_rows = num_rows + 1;
      _pdm_debug("num_rows = <%d>", (char *)num_rows);
      }
    }
    }

  if (row)
    free(row);
        
  /* format data buffer with sorted attribute buffer */
  if (PDU_command == PDC_M_MODIFY_CATALOG)
    status = PDUupdate_data_buffer(sort_data, *sort_attr);
   else
    status = PDUupdate_parm_data_buffer(sort_data, *sort_attr);
  _pdm_status("PDUupdate_data_buffers", status);
  if (status != PDM_S_SUCCESS)
    return(PDM_S_SUCCESS);
  
  status = MEMbuild_array(data_bufr);
  _pdm_status("MEMbuild_array", status);

  if (status != MEM_S_SUCCESS)
  return(PDM_S_SUCCESS);

  status = MEMbuild_array(*sort_data);
  _pdm_status("MEMbuild_array", status);

  if (status != MEM_S_SUCCESS)
    return(PDM_E_BUILD_BUFFER_ARRAY);

  sort_col = (char **) (*sort_data)->column_ptr;
  data_col = (char **) data_bufr->column_ptr;
  data_data = (char **) data_bufr->data_ptr;

  char_index = 0;
  row = (char *)malloc((*sort_data)->row_size);
  memset(row, NULL, (*sort_data)->row_size);

  for (i = 0; i < (*sort_data)->columns; i ++)
    {
    for(j = 0; j < data_bufr->columns; j++)
      {
      if (strcmp(sort_col[i], data_col[j]) == 0)
        {
        /* put this in string to write to buffer */
         if ((strlen(data_data[j])) && (data_data[j]))
           PDUadd_buffer_string(row, &char_index, data_data[j]);
         else
           row[char_index++] = '\1';
         break;
        }
      }
    }

  status = MEMwrite(*sort_data, row);
  _pdm_status("MEMwrite", status);

  if (row)
    free(row);
  if (status != MEM_S_SUCCESS)
    {
    if (*sort_attr)
       MEMclose(sort_attr);
    if (*sort_data)
       MEMclose(sort_data);
    return(PDM_E_WRITE_BUFFER);
    }

  if (PDM_debug_on)
    {
    MEMprint_buffer("sorted attribute buffer", *sort_attr, PDU_DEBUG_FILE);
    MEMprint_buffer("sorted data buffer", *sort_data, PDU_DEBUG_FILE);
    }

  return(PDM_S_SUCCESS);
  }

int PDUcheck_if_attribute_already_created()

  {
  int status;
  char **save_data = NULL;
  int i;
  int FOUND;

  _pdm_debug("In PDUcheck_if_attribute_already_created", 0);
  _pdm_debug("Attribute_name = <%s>", PDU_attr_name);

  status = MEMbuild_array(PDU_save_attr_bufr);
  _pdm_status("MEMbuild_array", status);

  if (status != MEM_S_SUCCESS)
    return(PDM_E_BUILD_BUFFER_ARRAY);

  save_data = (char **)PDU_save_attr_bufr->data_ptr;

  FOUND = FALSE;
  for (i = 0; i < PDU_save_attr_bufr->rows; i ++)
   {
   if (strcmp(PDU_attr_name, save_data[(PDU_save_attr_bufr->columns * i) +
       PDU_NFM_ATTR_COL]) == 0)
     {
     _pdm_debug("Attribute already existed before this session", 0);
     FOUND = TRUE;
     break;
     } 
   }

  return(FOUND);
  }

int PDUconvert_parametric_datatype(text,datatype)

  char *text;
  char **datatype;

  {

  _pdm_debug("In PDUconvert_parametric_datatype", 0);
  _pdm_debug("Old datatype = <%s>", *datatype);

   if (strcmp(text,"Point") == 0 )
     PDUfill_in_string(datatype,PDM_DATATYPE_POINT) ;
   else if (strcmp(text,"Coord sys") == 0 )
     PDUfill_in_string(datatype,PDM_DATATYPE_COORDSYS) ;
   else if (strcmp(text,"Line") == 0 )
     PDUfill_in_string(datatype,PDM_DATATYPE_LINE) ;
   else if (strcmp(text,"Conic") == 0 )
     PDUfill_in_string(datatype,PDM_DATATYPE_CONIC) ;
   else if (strcmp(text,"Circle") == 0 )
     PDUfill_in_string(datatype,PDM_DATATYPE_CIRCLE) ;
   else if (strcmp(text,"Arc") == 0 )
     PDUfill_in_string(datatype,PDM_DATATYPE_ARC) ;
   else if (strcmp(text,"Lbs") == 0 )
     PDUfill_in_string(datatype,PDM_DATATYPE_LBS);
   else if (strcmp(text,"Plane") == 0 )
     PDUfill_in_string(datatype,PDM_DATATYPE_PLANE);
   else if (strcmp(text,"Curve") == 0 )
     PDUfill_in_string(datatype,PDM_DATATYPE_CURVE);
   else if (strcmp(text,"Expression double") == 0 )
     PDUfill_in_string(datatype,PDM_DATATYPE_DOUBLE);
   else if (strcmp(text,"Expression text") == 0 )
     PDUfill_in_string(datatype,PDM_DATATYPE_TEXT);
   else if (strcmp(text,"Macro") == 0 )
     PDUfill_in_string(datatype,PDM_DATATYPE_MACRO);
   else 
     PDUfill_in_string(datatype,"char(10)");

  return(PDM_S_SUCCESS);
}

int PDUconvert_to_iotype(text,datatype, type)

  char *text;
  char **datatype;
  char *type;

  {

  _pdm_debug("In PDUconvert_to_iotype", 0);
  _pdm_debug("Old datatype = <%s>", *datatype);

   if (strcmp(text,"Point") == 0 )
     PDUfill_in_string(datatype,PDM_IOTYPE_LOCATE) ;
   else if (strcmp(text,"Coord sys") == 0 )
     PDUfill_in_string(datatype,PDM_IOTYPE_LOCATE) ;
   else if (strcmp(text,"Line") == 0 )
     PDUfill_in_string(datatype,PDM_IOTYPE_LOCATE) ;
   else if (strcmp(text,"Conic") == 0 )
     PDUfill_in_string(datatype,PDM_IOTYPE_LOCATE) ;
   else if (strcmp(text,"Circle") == 0 )
     PDUfill_in_string(datatype,PDM_IOTYPE_LOCATE) ;
   else if (strcmp(text,"Arc") == 0 )
     PDUfill_in_string(datatype,PDM_IOTYPE_LOCATE) ;
   else if (strcmp(text,"Lbs") == 0 )
     PDUfill_in_string(datatype,PDM_IOTYPE_LOCATE);
   else if (strcmp(text,"Plane") == 0 )
     PDUfill_in_string(datatype,PDM_IOTYPE_LOCATE);
   else if (strcmp(text,"Curve") == 0 )
     PDUfill_in_string(datatype,PDM_IOTYPE_LOCATE);
   else if ((strcmp(text,"Expression double") == 0 ) && 
            (strcmp(type, "Static") != 0))
     PDUfill_in_string(datatype,"D");
   else if (strcmp(text, "Expression double") == 0)
     PDUfill_in_string(datatype,PDM_IOTYPE_STATIC);
   else if ((strcmp(text,"Expression text") == 0 ) &&
            (strcmp(type, "Static") != 0))
     PDUfill_in_string(datatype,"D");
   else if (strcmp(text,"Expression text") == 0 )
     PDUfill_in_string(datatype,PDM_IOTYPE_STATIC);
   else if (strcmp(text,"Macro") == 0 )
     PDUfill_in_string(datatype,PDM_IOTYPE_STATIC);
   else
     PDUfill_in_string(datatype,PDM_IOTYPE_LOCATE) ;

  return(PDM_S_SUCCESS);
}

int PDUget_catalog_description()

  {
  int status = PDM_S_SUCCESS;
  int i;
  MEMptr buffer = NULL;
  char **buffer_data = NULL;

  _pdm_debug("In the function PDUget_catalog_description", 0);

  status = PDMshow_catalogs("","","PDM",&buffer);
  _pdm_status("PDMshow_catalog_description", status);

  if (buffer->rows >0)
    {
    status = MEMbuild_array(buffer);
    _pdm_status("MEMbuild_array", status);

    buffer_data = (char **)buffer->data_ptr;

   for (i = 0; i < buffer->rows; i++)
     if (strcmp(refresh->rev_catalog, 
         buffer_data[(buffer->columns * i) + 0]) == 0)
       {
       PDUfill_in_string(&PDU_cat_description,
                         buffer_data[(buffer->columns * i) + 1]);
       break;
       }
   }
  return(PDM_S_SUCCESS);
  }

int PDUcreate_class_and_catalog_bufr(in_buffer, out_buffer)

  MEMptr in_buffer;
  MEMptr *out_buffer;

  {
  int status;
  int i;
  char **in_data = NULL;
  char *row = NULL;

  _pdm_debug("In PDUcreate_class_and_catalog_bufr", 0);

  status = PDUformat_catalog_list_bufr(out_buffer);
  _pdm_status("PDUformat_catalog_list_bufr", status);

  if (status != PDM_S_SUCCESS)
    return(status);

  /* write information from PDMquery_classification */
  status = MEMbuild_array(in_buffer);
  _pdm_status("MEMbuild_array", status);

  if (status != MEM_S_SUCCESS)
    return(PDM_E_BUILD_BUFFER_ARRAY);

  in_data = (char **)in_buffer->data_ptr;
  row = (char *)malloc((*out_buffer)->row_size);
  /* loop through and extract class level first */
  for ( i = 0; i < in_buffer->rows; i++)
    {
    if ((in_data[(in_buffer->columns * i) + 1]) && 
        (strcmp(in_data[(in_buffer->columns * i) + 1], "") != 0))
      {
       memset(row, NULL, (*out_buffer)->row_size);
       sprintf(row, "%s\1%s\1", in_data[(in_buffer->columns * i) + 1],
                                in_data[(in_buffer->columns * i) + 3]);
       _pdm_debug("row = <%s>", row);
       status = MEMwrite(*out_buffer, row);
       _pdm_status("MEMwrite", status);

       if (status != MEM_S_SUCCESS)
          break;
       }
      }

   if (status != MEM_S_SUCCESS)
     return(PDM_E_FAILURE);

  return(PDM_S_SUCCESS);
  }

int PDUcreate_list_of_cat_attributes(in_buffer, out_buffer)

  MEMptr in_buffer;
  MEMptr *out_buffer;

  {
  int status;
  int i;
  char **in_data = NULL;
  char *row = NULL;

  _pdm_debug("In PDUcreate_list_of_cat_attributes", 0);

  status = PDUformat_catalog_list_bufr(out_buffer);
  _pdm_status("PDUformat_catalog_list_bufr", status);

  if (status != PDM_S_SUCCESS)
    return(status);

  /* write information from PDMquery_classification */
  status = MEMbuild_array(in_buffer);
  _pdm_status("MEMbuild_array", status);

  if (status != MEM_S_SUCCESS)
    return(PDM_E_BUILD_BUFFER_ARRAY);

  in_data = (char **)in_buffer->data_ptr;
  row = (char *)malloc((*out_buffer)->row_size);
  /* loop through and extract class level first */
  for ( i = 0; i < in_buffer->rows; i++)
    {
    if ((strncmp(in_data[(in_buffer->columns * i) + PDU_NFM_ATTR_COL], "n_",2)
           == 0) ||
        ((strncmp(in_data[(in_buffer->columns * i) + PDU_NFM_ATTR_COL], "p_",2) 
          == 0) && 
       (strcmp(in_data[(in_buffer->columns * i) + PDU_NFM_ATTR_COL], "p_sketch")
          != 0) && 
       (strcmp(in_data[(in_buffer->columns * i) + PDU_NFM_ATTR_COL], "p_macro")
          != 0) && 
    (strcmp(in_data[(in_buffer->columns * i) + PDU_NFM_ATTR_COL], "p_altpartno")
          != 0) && 
      (strcmp(in_data[(in_buffer->columns * i) + PDU_NFM_ATTR_COL], "p_flatten")
          != 0)))
     continue;
   if (strcmp(in_data[(in_buffer->columns * i) + PDU_NFM_READ_COL], "Y") == 0)
    {
    if ((in_data[(in_buffer->columns * i) + 1]) && 
        (strcmp(in_data[(in_buffer->columns * i) + PDU_NFM_SYN_COL], 
        "") != 0))
      {
       memset(row, NULL, (*out_buffer)->row_size);
      sprintf(row, "%s\1", in_data[(in_buffer->columns * i) + PDU_NFM_SYN_COL]);
       _pdm_debug("row = <%s>", row);
       status = MEMwrite(*out_buffer, row);
       _pdm_status("MEMwrite", status);

       if (status != MEM_S_SUCCESS)
          break;
       }
     else
      {
       memset(row, NULL, (*out_buffer)->row_size);
     sprintf(row, "%s\1", in_data[(in_buffer->columns * i) + PDU_NFM_ATTR_COL]);
       _pdm_debug("row = <%s>", row);
       status = MEMwrite(*out_buffer, row);
       _pdm_status("MEMwrite", status);

       if (status != MEM_S_SUCCESS)
          break;
       }
       }
      }

   if (status != MEM_S_SUCCESS)
     return(PDM_E_FAILURE);

  return(PDM_S_SUCCESS);
  }

int PDUget_filename_for_part(catalog, partid, revision, filename)

char *catalog;
char *partid; 
char *revision;
char **filename;

  {
  MEMptr ret_bufr = NULL;
  int file_col;
  int status;
  char **data_row = NULL;
  
  _pdm_debug("In PDUget_filename_for_part", 0);
  status = PDMget_filenames(catalog,partid,revision, &ret_bufr);
  _pdm_status("PDMget_filenames", status);

  if ((ret_bufr) && (ret_bufr->rows > 0))
    {
    MEMbuild_array(ret_bufr);
    status = PDUget_buffer_col(ret_bufr, "n_cofilename", &file_col);
    if (status != PDM_S_SUCCESS)
      return(status);

    PDUsetup_buffer(ret_bufr, ROW, &data_row);

    PDUfill_in_string(filename, data_row[(ret_bufr->columns*0)+file_col]);
    }
  else
    PDUfill_in_string(filename, "");

  _pdm_debug("filename = <%s>", *filename);
  return(PDM_S_SUCCESS);
  }

int PDUget_parttype(catalog, part, revision,parttype)

char* catalog;
char *part;
char *revision;
char **parttype;

  {
  int status;
  int type_col;
  char **list_row = NULL;
  MEMptr buffer = NULL;

  _pdm_debug("In PDUget_parttype", 0);

  status = PDMquery_part_type(catalog, part, revision, &buffer);
    _pdm_status("PDMquery_part_type", status);

  if ((buffer) && (status == PDM_S_SUCCESS))
    {
    MEMbuild_array(buffer);
    status = PDUget_buffer_col(buffer, "p_parttype", &type_col);
    if (status != PDM_S_SUCCESS)
      return(status);

    PDUsetup_buffer(buffer, ROW, &list_row);

    PDUfill_in_string(parttype,
                list_row[(buffer->columns * 0) + type_col]);
    _pdm_debug("parttype = <%s>", *parttype);
    MEMclose(&buffer);
    }

  return(status);
  }

int PDUcreate_dynamic_arrays(dyn_attr, dyn_data, dyn_count, dyn_attr_names, 
                             dyn_attr_values)

MEMptr dyn_attr;
MEMptr dyn_data;
int *dyn_count;
char ***dyn_attr_names;
char ***dyn_attr_values;
  {
  int status;
  int i;
  int length;
  char **dyn_attr_data = NULL;
  char **dyn_data_data = NULL;

  _pdm_debug("PDUcreate_dynamic_arrays", 0);

  if (dyn_attr == NULL)
    {
    *dyn_count = 0;
    return(PDM_S_SUCCESS);
    }
  else if (dyn_attr->rows == 0)
    {
    *dyn_count = 0;
    return(PDM_S_SUCCESS);
    }
  else if (dyn_data == NULL)
    {
    *dyn_count = 0;
    return(PDM_S_SUCCESS);
    }
  else if (dyn_data->rows == 0)
    {
    *dyn_count = 0;
    return(PDM_S_SUCCESS);
    }

  status = MEMbuild_array(dyn_attr);
  _pdm_status("MEMbuild_array", status);
  if (status != MEM_S_SUCCESS)
    return(PDM_E_BUILD_BUFFER_ARRAY);
 
  status = MEMbuild_array(dyn_data);
  _pdm_status("MEMbuild_array", status);
  if (status != MEM_S_SUCCESS)
    return(PDM_E_BUILD_BUFFER_ARRAY);
  
  dyn_attr_data = (char **)dyn_attr->data_ptr;
  dyn_data_data = (char **)dyn_data->data_ptr;

  _pdm_debug("malloc arrays", 0);
  *dyn_attr_names = (char **)malloc(sizeof (char *) * dyn_attr->rows);
  memset(*dyn_attr_names, NULL, sizeof (char *) * dyn_attr->rows);
  *dyn_attr_values = (char **)malloc(sizeof (char *) * dyn_data->rows);
  memset(*dyn_attr_values, NULL, sizeof (char *) * dyn_data->rows);

  for (i = 0; i < dyn_attr->rows; i++)
    {
    _pdm_debug("i = <%d>", i);
    _pdm_debug("attr_name = %s",
                dyn_attr_data[(dyn_attr->columns * i) + PDU_DYN_ATTR_COL]);
    length = strlen(dyn_attr_data[(dyn_attr->columns * i) + 
             PDU_DYN_ATTR_COL]);
     (*dyn_attr_names)[i] = (char *)malloc(sizeof (char) * (length + 1));
     strcpy((*dyn_attr_names)[i], dyn_attr_data[(dyn_attr->columns * i) + 
            PDU_DYN_ATTR_COL]);
    _pdm_debug("(*dyn_attr_names)[i] = <%s>", (*dyn_attr_names)[i]);

    length = strlen(dyn_data_data[(dyn_data->columns * i) + 
             PDU_DYN_DEFAULT_VAL_COL]);
     _pdm_debug("length = <%d>", length);
     (*dyn_attr_values)[i] = (char *)malloc(sizeof (char) * (length + 1));
     strcpy((*dyn_attr_values)[i], dyn_data_data[(dyn_data->columns * i) + 
            PDU_DYN_DEFAULT_VAL_COL]);
    _pdm_debug("(*dyn_attr_values)[i] = <%s>", (*dyn_attr_values)[i]);
    }
  *dyn_count = dyn_attr->rows;
  return(PDM_S_SUCCESS);
  }
    
void PDUcleanup_refresh()

  {
  _pdm_debug("In PDUcleanup_refresh", 0);

  if ((refresh->rev_catalog) && (strcmp(refresh->rev_catalog, "") != 0))
    PDUfill_in_string(&refresh->rev_catalog, "");
  if ((refresh->rev_partid) && (strcmp(refresh->rev_partid, "") != 0))
    PDUfill_in_string(&refresh->rev_partid, "");
  if ((refresh->rev_revision) && (strcmp(refresh->rev_revision, "") != 0))
    PDUfill_in_string(&refresh->rev_revision, "");
  if ((refresh->rev_filename) && (strcmp(refresh->rev_filename, "") != 0))
    PDUfill_in_string(&refresh->rev_filename, "");
  if ((refresh->rev_description) && (strcmp(refresh->rev_description, "") != 0))
    PDUfill_in_string(&refresh->rev_description, "");
  if ((refresh->rev_parttype) && (strcmp(refresh->rev_parttype, "") != 0))
    PDUfill_in_string(&refresh->rev_parttype, "");

  }
