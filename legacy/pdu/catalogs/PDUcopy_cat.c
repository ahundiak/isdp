#include        <stdio.h>
#include        <NFMerrordef.h>
#include	<PDUerror.h>
#include	<PDUstr.h>
#include	<PDUstorage.h>
#include	<PDMtypes.h>
#include	<PDUcommand.h>
#include	<PDUuser.h>
#include	<PDUfile_def.h>
#include	<PDMmessage.h>
#include	<MEMerrordef.h>
#include	<FI.h>
#include	<PDUproto.h>

/* added for pdu20 */
extern char *PDU_template_catalog;
extern char *PDU_cat_description;
extern char *PDU_cat_aclno;
extern char *PDU_dynamic_table;
extern int  PDU_required_attr;
extern int  PDU_user_attr;
extern int  PDU_parm_cat;
extern int  PDU_view;
extern int  PDM_debug_on;
extern char *PDU_cat_atr;
extern char *PDU_cat_data;
extern char *PDU_cat_list;
extern char *PDU_dyn_data;
extern char *PDU_dyn_attr;
extern char *PDU_dyn_list;
extern char *PDU_message;
extern MEMptr PDU_cat_class_bufr;
extern MEMptr PDU_cat_func_bufr;
extern MEMptr PDU_parameter_buffer;
    
int  PDUcreate_like_catalog()

/******************************************************************************

Doc:	PDUcreate_like_catalog

Abstract:
	
Algorithm:

Return Status:

Caveats:

History:

*****************************************************************************/

  {
  int		            	status = PDM_S_SUCCESS; /* PDM status	*/
  long		            	status1 = NFM_S_SUCCESS; /* NFM status	*/
  MEMptr			loc_attr = NULL; /* loc attributes */
  MEMptr			loc_data = NULL; /* loc attribute data */
  MEMptr			loc_list = NULL; /* loc value list */
  MEMptr 		        cat_attr = NULL; /* catalog attributes */
  MEMptr			cat_data = NULL; /* catalog data */
  MEMptr			cat_list = NULL; /* catalog list of values */
  MEMptr			dyn_attr = NULL; /* catalog dyn attr names */
  MEMptr			dyn_data = NULL; /* catalog dyn attr values */
  MEMptr			dyn_list = NULL; /* catalog dyn attr values */
  MEMptr			macro_buffer = NULL; 
  int				attr_row;
  int				cat_no;
  extern struct PDUrefresh	*refresh;
  extern struct PDUuser	        *user;
  extern struct PDUstorage	*storage;

  _pdm_debug("In the copy and change catalog function", 0);
  
    /* get catalog buffers from global variables */
    cat_attr = (MEMptr)PDU_cat_atr;
    cat_data = (MEMptr)PDU_cat_data;
    cat_list = (MEMptr)PDU_cat_list;
    dyn_attr = (MEMptr)PDU_dyn_attr;
    dyn_data = (MEMptr)PDU_dyn_data;
    dyn_list = (MEMptr)PDU_dyn_list;

  /* get the loc attributes needed to add a catalog */
  status = PDMget_table_data(ADD_DATA, PDM_LOC, /* catalog name */ "",
		/* part id */ "", /* revision */ "", &loc_attr, &loc_data,
		&loc_list);
  _pdm_status ("PDMget_table_data", status );

  if (status != PDM_S_SUCCESS)
    {
    PDUfill_in_string(&PDU_message, 
                      "Unable to get catalog attributes for new catalog");
    return(status);
    }

  status = MEMbuild_array(loc_attr);
  _pdm_status("MEMbuild_array", status);

  if (status != MEM_S_SUCCESS)
    {
    PDUfill_in_string(&PDU_message, "Error building buffer array");
    return(PDM_E_BUILD_BUFFER_ARRAY);
    }

  status = MEMbuild_array(loc_data);
  _pdm_status("MEMbuild_array", status);

  if (status != MEM_S_SUCCESS)
    {
    PDUfill_in_string(&PDU_message, "Error building buffer array");
    return(PDM_E_BUILD_BUFFER_ARRAY);
    }

  /* put the catalog application in the buffer */
  attr_row = PDUfind_attr_in_buffer(loc_attr, PDU_NFM_CATALOG_APPL);
  if (attr_row != -1)
    {
    status = MEMwrite_data(loc_data, "PDM", 1, (attr_row + 1));
    _pdm_status("MEMwrite_data", status);

    if (status != MEM_S_SUCCESS)
      {
      PDUfill_in_string(&PDU_message, "Error writing data to buffer");
      return(PDM_E_WRITE_BUFFER);
      }

    }
  /* put the catalog type in the buffer */
  if ((PDU_parm_cat) && (PDU_view))
  {
  attr_row = PDUfind_attr_in_buffer(loc_attr, PDU_NFM_CATALOG_TYPE);
  if (attr_row != -1)
    {
    status = MEMwrite_data(loc_data, "CID", 1, (attr_row + 1));
    _pdm_status("MEMwrite_data", status);

   if (status != MEM_S_SUCCESS)
     {
     PDUfill_in_string(&PDU_message, "Error writing data to buffer");
     return(PDM_E_WRITE_BUFFER);
     }
    }
    }
    else 
    {
    status = MEMbuild_array(cat_attr);
    _pdm_status("MEMbuild_array", status);
    if (status != MEM_S_SUCCESS)
      return(PDM_E_BUILD_BUFFER_ARRAY);
    attr_row = PDUfind_attr_in_buffer(cat_attr, "p_altpartno");
    if (attr_row != -1)
    {
    _pdm_debug("catalog type is EXT or PXT", 0);
    attr_row = PDUfind_col_in_buffer(loc_data, PDU_NFM_CATALOG_TYPE);
    if (attr_row != -1)
      {
        if (PDU_parm_cat)
          status = MEMwrite_data(loc_data, "PXT", 1, (attr_row + 1));
        else
          status = MEMwrite_data(loc_data, "EXT", 1, (attr_row + 1));
        _pdm_status("MEMwrite_data", status);

        if (status != MEM_S_SUCCESS)
          {
          PDUfill_in_string(&PDU_message, "Error in writing data to buffer");
          return(PDM_E_WRITE_BUFFER);
          }
      }
     }
     else if ((dyn_attr) && (dyn_attr->rows > 0))
     {
    status = MEMbuild_array(dyn_attr);
    _pdm_status("MEMbuild_array", status);
    if (status != MEM_S_SUCCESS)
      return(PDM_E_BUILD_BUFFER_ARRAY);
    attr_row = PDUfind_attr_in_buffer(dyn_attr, "p_altpartno");
    if (attr_row != -1)
    {
    _pdm_debug("catalog type is EXT or PXT", 0);
    attr_row = PDUfind_col_in_buffer(loc_data, PDU_NFM_CATALOG_TYPE);
    if (attr_row != -1)
      {
        if (PDU_parm_cat)
          status = MEMwrite_data(loc_data, "PXT", 1, (attr_row + 1));
        else
          status = MEMwrite_data(loc_data, "EXT", 1, (attr_row + 1));
        _pdm_status("MEMwrite_data", status);

        if (status != MEM_S_SUCCESS)
          {
          PDUfill_in_string(&PDU_message, "Error in writing data to buffer");
          return(PDM_E_WRITE_BUFFER);
          }
      }
     }
  else if (PDU_parm_cat)
  {
  attr_row = PDUfind_attr_in_buffer(loc_attr, PDU_NFM_CATALOG_TYPE);
  if (attr_row != -1)
    {
    status = MEMwrite_data(loc_data, "P", 1, (attr_row + 1));
    _pdm_status("MEMwrite_data", status);

   if (status != MEM_S_SUCCESS)
     {
     PDUfill_in_string(&PDU_message, "Error writing data to buffer");
     return(PDM_E_WRITE_BUFFER);
     }
    }
    }
   else
    {
    attr_row = PDUfind_col_in_buffer(loc_data, PDU_NFM_CATALOG_TYPE);
    if (attr_row != -1)
      {
        status = MEMwrite_data(loc_data, "C", 1, (attr_row + 1));
        _pdm_status("MEMwrite_data", status);

        if (status != MEM_S_SUCCESS)
          {
          PDUfill_in_string(&PDU_message, "Error in writing data to buffer");
          return(PDM_E_WRITE_BUFFER);
          }
      }
     }
     }
  else if (PDU_parm_cat)
  {
  attr_row = PDUfind_attr_in_buffer(loc_attr, PDU_NFM_CATALOG_TYPE);
  if (attr_row != -1)
    {
    status = MEMwrite_data(loc_data, "P", 1, (attr_row + 1));
    _pdm_status("MEMwrite_data", status);

   if (status != MEM_S_SUCCESS)
     {
     PDUfill_in_string(&PDU_message, "Error writing data to buffer");
     return(PDM_E_WRITE_BUFFER);
     }
    }
    }
   else
    {
    attr_row = PDUfind_col_in_buffer(loc_data, PDU_NFM_CATALOG_TYPE);
    if (attr_row != -1)
      {
        status = MEMwrite_data(loc_data, "C", 1, (attr_row + 1));
        _pdm_status("MEMwrite_data", status);

        if (status != MEM_S_SUCCESS)
          {
          PDUfill_in_string(&PDU_message, "Error in writing data to buffer");
          return(PDM_E_WRITE_BUFFER);
          }
      }
     }
    }

  /* put the new catalog name refresh->rev_catalog in the buffer */
  attr_row = PDUfind_attr_in_buffer(loc_attr, PDU_NFM_CATALOG_NAME);
  if (attr_row != -1)
    {
    status = MEMwrite_data(loc_data, refresh->rev_catalog, 1, (attr_row + 1));
    _pdm_status("MEMwrite_data", status);

   if (status != MEM_S_SUCCESS)
     {
     PDUfill_in_string(&PDU_message, "Error writing data to buffer");
     return(PDM_E_WRITE_BUFFER);
     }
    }

  /* put the new catalog description in the buffer */
  attr_row = PDUfind_attr_in_buffer(loc_attr, PDU_NFM_CATALOG_DESC);
  if (attr_row != -1)
    {
    status = MEMwrite_data(loc_data, PDU_cat_description, 1, (attr_row + 1));
    _pdm_status("MEMwrite_data", status);

   if (status != MEM_S_SUCCESS)
     {
     PDUfill_in_string(&PDU_message, "Error writing data to buffer");
     return(PDM_E_WRITE_BUFFER);
     }
    }

  /* put the new catalog ACL fot the catalog in the buffer */
  attr_row = PDUfind_attr_in_buffer(loc_attr, PDU_NFM_ACL_NO);
  if (attr_row != -1) 
    {
    status = MEMwrite_data(loc_data, PDU_cat_aclno, 1, (attr_row + 1));
    _pdm_status("MEMwrite_data", status);

   if (status != MEM_S_SUCCESS)
     {
     PDUfill_in_string(&PDU_message, "Error writing data to buffer");
     return(PDM_E_WRITE_BUFFER);
     }
    }

  /* if catalog attribute form was displayed, the catalog buffers already
     exist in global variables. Otherwise, get the buffers from PDM */

  /* add the catalog to the PDM database */
  if ( PDM_debug_on )
    {
    MEMprint_buffer("loc attr", loc_attr, PDU_DEBUG_FILE);
    MEMprint_buffer("loc data", loc_data, PDU_DEBUG_FILE);
    MEMprint_buffer("cat attr", cat_attr, PDU_DEBUG_FILE);
    MEMprint_buffer("cat data", cat_data, PDU_DEBUG_FILE);
    MEMprint_buffer("cat list", cat_list, PDU_DEBUG_FILE);
    MEMprint_buffer("dyn_attr buff",dyn_attr,PDU_DEBUG_FILE);
    MEMprint_buffer("dyn_data buff",dyn_data,PDU_DEBUG_FILE);
    }

  /* call NFMrtic_it to find ' in the data buffer */
      status1 = NFMRtic_it( loc_data );

      status1 = NFMRtic_it( cat_data );

      status1 = NFMRtic_it( dyn_data );

      status1 = NFMRtic_it( cat_attr );

      status1 = NFMRtic_it( dyn_attr );

      status = PDM_S_SUCCESS;

      /*status = PDMcopy_catalog_functions(PDU_template_catalog, 
                                         refresh->rev_catalog);
      _pdm_status("PDMcopy_catalog_functions", status);*/

      if (PDU_cat_func_bufr)
        {
        /* get storage_name from global buffer */
        if (PDM_debug_on)
          MEMprint_buffer("function buffer", PDU_cat_func_bufr,
                           PDU_DEBUG_FILE);
         _pdm_debug("storage->storage_name = <%s>", storage->storage_name);
         status = PDMmap_attribute_functions(refresh->rev_catalog,
                                              storage->storage_name,
                                              PDU_cat_func_bufr);
         _pdm_status("PDMmap_attribute_functions", status1);
         }

      /* add the catalog to the PDM database */
      if ((!PDU_parm_cat) && (status == PDM_S_SUCCESS))
      {
      status = PDMrcreate_catalog(loc_attr, loc_data, cat_attr,
                               cat_data, cat_list, PDU_dynamic_table,dyn_attr,
                               dyn_data,dyn_list);
      _pdm_status("PDMrcreate_catalog", status );
      }
      else if (status == PDM_S_SUCCESS)
      {
        PDUload_exec_structure("","","N", "", "","","",
                               0, 0);
      PDUmessage(PDS_M_CREATE_CATALOG, 's');
      status = PDMcreate_parametric_catalog(loc_attr, loc_data, cat_attr,
                               cat_data, cat_list, PDU_dynamic_table,dyn_attr,
                               dyn_data,dyn_list);

      _pdm_status("PDMrcreate_parametric_catalog", status );
      }

      if ((PDU_cat_class_bufr) && (status == PDM_S_SUCCESS))
        {
        _pdm_debug("Define catalog classification", 0);
        if (PDM_debug_on)
          MEMprint_buffer("classification_buffer", PDU_cat_class_bufr,
                           PDU_DEBUG_FILE);
         status = PDMstore_classification(PDU_cat_class_bufr);
         _pdm_status("PDMstore_classification", status);
         if ((status != PDM_S_SUCCESS) && (!PDU_parm_cat))
           {
           status = PDMrdelete_catalog(
                                         refresh->rev_catalog);
           _pdm_status("PDMrdelete_catalog", status);
           }
        else if ((status != PDM_S_SUCCESS) && (PDU_parm_cat) && (!PDU_view))
           {
           status = PDMdelete_parametric_catalog(user->user_id,
                                        refresh->rev_catalog,
                                        &cat_no);
            _pdm_status("PDMdelete_parametric_catalog", status);
           }
         }

      if ((PDU_parm_cat) && (status == PDM_S_SUCCESS))
        {
        _pdm_debug("storing parameters", 0);
        if (PDM_debug_on)
          MEMprint_buffer("parameter_buffer", PDU_parameter_buffer,
                           PDU_DEBUG_FILE);
        status = PDMstore_parameters(PDU_parameter_buffer);
        _pdm_status("PDMstore_parameters", status);

        if ((status != PDM_S_SUCCESS) && (PDU_parm_cat) && (!PDU_view))
           {
           status = PDMdelete_parametric_catalog(user->user_id,
                                        refresh->rev_catalog,
                                        &cat_no);
            _pdm_status("PDMdelete_parametric_catalog", status);
           }

        if (PDU_parameter_buffer)
          {
          MEMclose(&PDU_parameter_buffer);
          PDU_parameter_buffer = NULL;
          }

        _pdm_debug("storing map", 0);
        status = PDUload_map_buffer(&macro_buffer);
        _pdm_status("PDUload_map_buffer", status);

        if (PDM_debug_on)
          MEMprint_buffer("map_buffer", macro_buffer,
                           PDU_DEBUG_FILE);
        status = PDMmap_catalog_macro(macro_buffer);
        _pdm_status("PDMmap_catalog_macro", status);

        if ((status != PDM_S_SUCCESS) && (PDU_parm_cat) && (!PDU_view))
           {
           status = PDMdelete_parametric_catalog(user->user_id,
                                        refresh->rev_catalog,
                                        &cat_no);
            _pdm_status("PDMdelete_parametric_catalog", status);
           }

         MEMclose(&macro_buffer);
        }


  /* if catalog was created successfully, put the catalog
     name in the refresh area */

  if (status == PDM_S_SUCCESS)
    _pdm_debug("Catalog <%s> created successfully", refresh->rev_catalog);
  else
    {
     _pdm_debug("Catalog <%s> no created successfully", refresh->rev_catalog);
     PDUfill_in_string(&PDU_message, "Error creating new catalog");
     }
   
  if ((PDU_template_catalog) && (strcmp(PDU_template_catalog, "") != 0))
    PDUfill_in_string(&PDU_template_catalog, NULL);
  if (PDU_cat_aclno)
    PDUfill_in_string(&PDU_cat_aclno, NULL);

  if (loc_attr)
    MEMclose(&loc_attr);
  if (loc_data)
    MEMclose(&loc_data);
  if (cat_attr)
    MEMclose(&cat_attr);
  if (cat_data)
    MEMclose(&cat_data);
  if (cat_list)
    MEMclose(&cat_list);
  if (dyn_attr)
    MEMclose(&dyn_attr);
  if (dyn_data)
    MEMclose(&dyn_data);

    
  refresh->status = status;
  return(status);
  }     

int PDUmerge_copycat_buffers(src_attr, new_attr)

MEMptr new_attr;
MEMptr *src_attr;

  {
  int status;
  int i;
  int attr_row = -1;
  char **src_data = NULL;
  char **new_data = NULL;

  _pdm_debug("In PDUmerge_copycat_buffers", 0);

  status = MEMbuild_array(new_attr);
  _pdm_status("MEMbuild_array", status);

  if (status != MEM_S_SUCCESS)
    return(PDM_E_BUILD_BUFFER_ARRAY);

  new_data = (char **)new_attr->data_ptr;

  status = MEMbuild_array(*src_attr);
  _pdm_status("MEMbuild_array", status);

  if (status != MEM_S_SUCCESS)
    return(PDM_E_BUILD_BUFFER_ARRAY);

  for (i = 0; i < new_attr->rows; i ++)
     {
     attr_row = PDUfind_attr_in_buffer(*src_attr, new_data[(new_attr->columns * i)
                                     + PDU_NFM_ATTR_COL]);
     /* write attrno and table no from new buffer into source buffer */
     status = MEMwrite_data(*src_attr, new_data[(new_attr->columns * i) + 
                            PDU_NFM_ATTRNO_COL], (attr_row + 1), 
                            (PDU_NFM_ATTRNO_COL + 1));
     _pdm_status("MEMwrite_data(attrno)", status);

     if (status != MEM_S_SUCCESS)
       return(PDM_E_WRITE_BUFFER);
     
     status = MEMwrite_data(*src_attr, new_data[(new_attr->columns * i) + 
                            PDU_NFM_TABLENO_COL], (attr_row + 1), 
                            (PDU_NFM_TABLENO_COL + 1));
     _pdm_status("MEMwrite_data(tableno)", status);
     
     if (status != MEM_S_SUCCESS)
       return(PDM_E_WRITE_BUFFER);
     } 

  /* blank out attrno and listno in source buffer for userdefined attributes */
  src_data = (char **)(*src_attr)->data_ptr;
  
  for (i = 0; i < (*src_attr)->rows; i ++)
    {
  if ((strncmp(src_data[((*src_attr)->columns * i) + PDU_NFM_ATTR_COL], "n_", 2)
      == 0) || (strncmp(src_data[((*src_attr)->columns * i) + PDU_NFM_ATTR_COL],
     "p_", 2) == 0))
       break;
    else 
      {
      status = MEMwrite_data(*src_attr, "", (i + 1), (PDU_NFM_ATTRNO_COL + 1));
      _pdm_status("MEMwrite_data", status);

     if (status != MEM_S_SUCCESS)
       return(PDM_E_WRITE_BUFFER);
      
      status = MEMwrite_data(*src_attr, "", (i + 1), (PDU_NFM_TABLENO_COL + 1));
      _pdm_status("MEMwrite_data", status);

     if (status != MEM_S_SUCCESS)
       return(PDM_E_WRITE_BUFFER);
     }
   }

  return(PDM_S_SUCCESS);
  }
      
