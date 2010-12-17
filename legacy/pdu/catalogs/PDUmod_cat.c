#include        <stdio.h>
#include        <NFMerrordef.h>
#include	<PDUerror.h>
#include	<PDUstr.h>
#include	<PDUuser.h>
#include	<PDUstorage.h>
#include	<PDMtypes.h>
#include	<PDUcommand.h>
#include	<PDUfile_def.h>
#include	<MEMerrordef.h>
#include	<PDUproto.h>
#include	<PDMproto.h>

int  PDUmodify_catalog()

/******************************************************************************

Doc:	PDUmodify_catalog

Abstract:
	
Algorithm:

Return Status:

Caveats:

History:

*****************************************************************************/

  {
  int		            	status = PDM_S_SUCCESS; /* PDM status	*/
  long                          status1 = NFM_S_SUCCESS;
  MEMptr			loc_attr = NULL;   /* loc attributes */
  MEMptr			loc_data = NULL;   /* loc attribute data */
  MEMptr			loc_list = NULL;   /* loc value list */
  MEMptr 		        cat_attr = NULL;    /* catalog attributes */
  MEMptr			cat_data = NULL;    /* catalog data */
  MEMptr			cat_list = NULL;   /* catalog list of values */
  MEMptr                        dyn_attr = NULL;   /* dyn attr buffer */
  MEMptr                        dyn_data = NULL;   /* dyn data buffer */
  MEMptr                        dyn_list = NULL;   /* dyn list buffer */
  int				attr_row;
  extern struct PDUrefresh	*refresh;
  extern struct PDUuser    	*user;
  extern struct PDUstorage	*storage;
  
  /* added for PDU2.0 */
  extern char *PDU_cat_description;
  extern char *PDU_cat_aclno;
  extern char *PDU_dynamic_table;
  extern int  PDU_required_attr;
  extern int  PDU_user_attr;
  extern int  PDU_parm_cat;
  extern int  PDU_view;
  extern int  PDM_debug_on;
  extern char *PDU_loc_attr;
  extern char *PDU_loc_data;
  extern char *PDU_loc_list;
  extern char *PDU_cat_atr;
  extern char *PDU_cat_data;
  extern char *PDU_cat_list;
  extern char *PDU_dyn_attr;
  extern char *PDU_dyn_data;
  extern char *PDU_dyn_list;
  extern char *PDU_message;
  extern MEMptr PDU_cat_class_bufr;
  extern MEMptr PDU_parameter_buffer;
  extern MEMptr PDU_macro_buffer;
  extern MEMptr PDU_cat_func_bufr;
    
  _pdm_debug("In the modify catalog function", 0);
    /* get buffers from global variables */
    cat_attr = (MEMptr)PDU_cat_atr;
    cat_data = (MEMptr)PDU_cat_data;
    cat_list = (MEMptr)PDU_cat_list;
    dyn_attr = (MEMptr)PDU_dyn_attr;
    dyn_data = (MEMptr)PDU_dyn_data;
    dyn_list = (MEMptr)PDU_dyn_list;
  
  if ((!PDU_parm_cat) && (!PDU_view))
  {
  /* get the loc attributes needed to add a catalog */
  status = PDMget_table_data(MODIFY_DATA, PDM_LOC,
		/* catalog name */ refresh->rev_catalog,
		/* part id */ "", /* revision */ "", &loc_attr, &loc_data,
		&loc_list);
  _pdm_status ("PDMget_table_data", status );

  if (status != PDM_S_SUCCESS)
    {
   PDUfill_in_string(&PDU_message, "Error getting catalog attributes from PDM");
    return(status);
    }
   }
  else if (PDU_parm_cat)
    {
    loc_attr = (MEMptr)PDU_loc_attr;
    loc_data = (MEMptr)PDU_loc_data;
    loc_list = (MEMptr)PDU_loc_list;
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
  attr_row = PDUfind_attr_in_buffer(loc_attr, PDU_NFM_CATALOG_NAME);
  if (attr_row != -1)
    {
    status = MEMwrite_data(loc_attr, "N", (attr_row + 1), 
        		  (PDU_NFM_UPDATE_COL + 1));
    _pdm_status("MEMwrite_data", status);

    if (status != MEM_S_SUCCESS)
      {
      PDUfill_in_string(&PDU_message, "Error writing data to buffer");
      return(PDM_E_WRITE_BUFFER);
      }
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
  if (!PDU_view) 
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
    _pdm_debug("catalog type is EXT", 0);
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
    attr_row = PDUfind_col_in_buffer(loc_data, PDU_NFM_CATALOG_TYPE);
    if (attr_row != -1)
      {
        status = MEMwrite_data(loc_data, "P", 1, (attr_row + 1));
        _pdm_status("MEMwrite_data", status);

        if (status != MEM_S_SUCCESS)
          {
          PDUfill_in_string(&PDU_message, "Error in writing data to buffer");
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
    attr_row = PDUfind_col_in_buffer(loc_data, PDU_NFM_CATALOG_TYPE);
    if (attr_row != -1)
      {
        status = MEMwrite_data(loc_data, "P", 1, (attr_row + 1));
        _pdm_status("MEMwrite_data", status);

        if (status != MEM_S_SUCCESS)
          {
          PDUfill_in_string(&PDU_message, "Error in writing data to buffer");
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

  /* put the new description in the buffer */
  attr_row = PDUfind_attr_in_buffer(loc_attr, PDU_NFM_CATALOG_DESC);
  if ((attr_row != -1 ) && ((PDU_cat_description != NULL)) &&
                           (strcmp(PDU_cat_description, "") != 0))
    {
    status = MEMwrite_data(loc_data, PDU_cat_description, 1, (attr_row + 1));
    _pdm_status("MEMwrite_data", status);

    if (status != MEM_S_SUCCESS)
      {
      PDUfill_in_string(&PDU_message, "Error writing data to buffer");
      return(PDM_E_WRITE_BUFFER);
      }
    }

  /* if the attribute form was displayed, the catalog buffers already exist
     in global variables. Otherwise get the buffers from PDM */

    if (PDM_debug_on)
      {
      MEMprint_buffer("loc attrs", loc_attr, PDU_DEBUG_FILE);
      MEMprint_buffer("loc data", loc_data, PDU_DEBUG_FILE);
      MEMprint_buffer("cat attrs", cat_attr, PDU_DEBUG_FILE);
      MEMprint_buffer("cat data", cat_data, PDU_DEBUG_FILE);
      MEMprint_buffer("cat list", cat_list, PDU_DEBUG_FILE);
      MEMprint_buffer("dyn attr", dyn_attr,PDU_DEBUG_FILE);
      MEMprint_buffer("dyn data", dyn_data,PDU_DEBUG_FILE);
      MEMprint_buffer("dyn list", dyn_list,PDU_DEBUG_FILE);
      }

    /* call NFMrtic_it to find ' in the data buffer */
    status1 = NFMRtic_it( loc_data );

    status1 = NFMRtic_it( cat_data );

    status1 = NFMRtic_it( dyn_data );

    status1 = NFMRtic_it( cat_attr );

    status1 = NFMRtic_it( dyn_attr );

      status = PDM_S_SUCCESS;
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

    /* modify catalog at host */
    if ((!PDU_view) &&  (!PDU_parm_cat))
    {
    status = PDMrmodify_catalog(loc_attr, loc_data, cat_attr, cat_data,
				cat_list, PDU_dynamic_table, 
                                dyn_attr, dyn_data,dyn_list);
    _pdm_status("PDMrmodify_catalog", status);
    }
    else if ((PDU_parm_cat) && (!PDU_view))
    {
    status = PDMchange_parametric_catalog(user->user_id, loc_attr, loc_data,
                                          cat_attr, cat_data, cat_list, 
                                          PDU_dynamic_table, dyn_attr, dyn_data,
                                          dyn_list);
    _pdm_status("PDMchange_parametric_catalog", status);
    }
    else 
    {
    status = PDMchange_view_catalog(user->user_id, loc_attr, loc_data,
                                          cat_attr, cat_data, cat_list, 
                                          PDU_dynamic_table, dyn_attr, dyn_data,
                                          dyn_list);
    _pdm_status("PDMchange_view_catalog", status);
    }
    if (status != PDM_S_SUCCESS)
      PDUfill_in_string(&PDU_message, "Error modifying catalog");

      if ((PDU_cat_class_bufr) && (status == PDM_S_SUCCESS))
        {
        _pdm_debug("Define catalog classification", 0);
        if (PDM_debug_on)
          MEMprint_buffer("classification_buffer", PDU_cat_class_bufr,
                           PDU_DEBUG_FILE);
         status = PDMstore_classification(PDU_cat_class_bufr);
         _pdm_status("PDMstore_classification", status);
         }

      if ((PDU_parm_cat) && (status == PDM_S_SUCCESS))
        {
        _pdm_debug("storing parameters", 0);
        if (PDM_debug_on)
          MEMprint_buffer("parameter_buffer", PDU_parameter_buffer,
                           PDU_DEBUG_FILE);
        status = PDMstore_parameters(PDU_parameter_buffer);
        _pdm_status("PDMstore_parameters", status);

        if (PDU_parameter_buffer)
          {
          MEMclose(&PDU_parameter_buffer);
          PDU_parameter_buffer = NULL;
          }

        _pdm_debug("storing map", 0);
        if (PDM_debug_on)
          MEMprint_buffer("map_buffer", PDU_macro_buffer,
                           PDU_DEBUG_FILE);
        status = PDMmap_catalog_macro(PDU_macro_buffer);
        _pdm_status("PDMmap_catalog_macro", status);

        if (PDU_macro_buffer)
          {
          MEMclose(&PDU_macro_buffer);
          PDU_macro_buffer = NULL;
          }
        }


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
    if (dyn_list)
      MEMclose(&dyn_list);

  refresh->status = status;

  return(status);
  }     

