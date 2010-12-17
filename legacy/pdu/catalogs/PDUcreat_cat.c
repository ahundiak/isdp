#include        <stdio.h>
#include        <FI.h>
#include        <NFMerrordef.h>
#include	<PDUstr.h>
#include	<PDUstorage.h>
#include	<PDUerror.h>
#include	<PDMtypes.h>
#include        <PDUforms.h>
#include        <PDUprompt.h>
#include        <PDUuser.h>
#include        <PDUfile_def.h>
#include        <PDMmessage.h>
#include	<MEMerrordef.h>
#include	<PDUproto.h>
#include	<PDMproto.h>

/* added for PDU2.0 */
extern char *PDU_cat_description;
extern char *PDU_cat_aclno;
extern int  PDU_required_attr;
extern int PDU_user_attr;
extern int PDU_parm_cat;
extern int PDU_view;
extern int PDM_debug_on;
extern struct PDUforms forms;
extern char *PDU_loc_data;
extern char *PDU_cat_atr;
extern char *PDU_cat_data;
extern char *PDU_cat_list;
extern char *PDU_dyn_attr;
extern char *PDU_dyn_data;
extern char *PDU_dyn_list;
extern char *PDU_message;
extern char *PDU_dynamic_table;
extern MEMptr PDU_cat_class_bufr;
extern MEMptr PDU_cat_func_bufr;
extern MEMptr PDU_parameter_buffer;
extern MEMptr PDU_storage_area;

int PDUcreate_catalog()

/******************************************************************************

Doc:	PDUcreate_catalog

Abstract:
	Creates a catalog for the PDM database by prompting for information
	needed for the NFM loc table about the catalog and allowing the user
	to modify a default set of attributes needed in every catalog and 
	allowing the definition of user attributes.  Each attribute may be 
	assigned an initial and/or default value and a list of values user may 
	select from.  If user attributes are added, the data buffer is rebuilt
	and contains a column for each new attribute added by the user.
	
Algorithm:
	.bp
		1.	Get the loc attributes which require information to add a catalog.
		2.	Display the loc attributes in a two column form for the user to input values.
		3.	Put the values entered into the loc data buffer.
		4.	Get the default set of attributes needed in every catalog.
		5.	Display these attributes in a three column form and the user may modify these or add additional ones.
		6.	Put the modifications and new attributes in the buffers.
		7.	If there are user defined attributes, update the data buffer to have a column for each of the user attributes.
		7.	Send the information defining the new catalog to PDM for creation.
	.ep

Return Status:
	PDM_S_SUCCESS           	-	Successful Completion.
	PDM_I_FORM_CANCEL       	-	User exited out of form.
	PDM_E_WRITE_BUFFER       	-	Could not write to user data to buffer.
	PDM_E_BUILD_BUFFER_ARRAY	-	Could not build pointers in buffer.
	PDM_E_NOREAD_ATTRS       	-	No attributes have read access.
	MEM_E_BAD_BUFFER_NO		-	Bad list buffer number
	MEM_E_NULL_LIST			-	Null address in buffer pointer
	MEM_E_NULL_BUFFER		-	Buffer is empty
	MEM_E_MALLOC			-	Could not open new buffer due to memory
	PDM_E_WRITE_FORMAT		-	Could not write format to new buffer

Caveats:

History:
	9/6/89	-	Documentation Date
*****************************************************************************/

  {
    int		status = PDM_S_SUCCESS; /* PDM status */
    long        status1 = NFM_S_SUCCESS;
    MEMptr	loc_attr = NULL; /* buffer of loc attributes */
    MEMptr	loc_data = NULL; /* buffer of loc attribute initial and default values */
    MEMptr	loc_list = NULL; /* buffer of lists for loc attributes */
    MEMptr	cat_attr = NULL; /* buffer of default catalog attributes and user defined attributes */
    MEMptr	cat_data = NULL; /* buffer of default and initial values for default and user defined attributes */
    MEMptr	cat_list = NULL; /* buffer of lists for catalog attributes */
    int		attr_row;
    int         cat_no;
    extern struct PDUrefresh *refresh; /* refresh area form data */
    extern struct PDUuser *user; /* refresh area form data */
    extern struct PDUstorage *storage;
    MEMptr      dyn_attr = NULL; /* dynamic attrributes buffer */
    MEMptr      dyn_data = NULL; /* dynamic data buffer */
    MEMptr      dyn_list = NULL;
    MEMptr      macro_buffer = NULL;
    
    _pdm_debug("In the PDUcreate_catalog function", 0);

      /* get global variables for catalog buffers */
      cat_attr = (MEMptr)PDU_cat_atr;
      cat_data = (MEMptr)PDU_cat_data;
      cat_list = (MEMptr)PDU_cat_list;
      dyn_attr = (MEMptr)PDU_dyn_attr;
      dyn_data = (MEMptr)PDU_dyn_data;
      dyn_list = (MEMptr)PDU_dyn_list;
    if (!PDU_view)
    {
    /* get the loc attributes needed to add a catalog */
    status = PDMget_table_data(ADD_DATA, PDM_LOC, /* catalog name */ "",
		/* part id */ "",/* revision */ "", &loc_attr, &loc_data,
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
      PDUfill_in_string(&PDU_message, "Error in building buffer array");
      return(PDM_E_BUILD_BUFFER_ARRAY);
      }

    }
   else
      loc_data = (MEMptr)PDU_loc_data;

    status = MEMbuild_array(loc_data);
    _pdm_status("MEMbuild_array", status);

    if (status != MEM_S_SUCCESS)
      {
      PDUfill_in_string(&PDU_message, "Error in building buffer array");
      return(PDM_E_BUILD_BUFFER_ARRAY);
      }

    /* put the catalog application in the buffer */
    attr_row = PDUfind_col_in_buffer(loc_data, PDU_NFM_CATALOG_APPL);
    _pdm_debug("attr_row = %d", (char *)attr_row);
    if (attr_row != -1)
      {
        status = MEMwrite_data(loc_data, "PDM", 1, (attr_row + 1));
        _pdm_status("MEMwrite_data", status);

        if (status != MEM_S_SUCCESS)
          {
          PDUfill_in_string(&PDU_message, "Error in writing data to buffer");
          return(PDM_E_WRITE_BUFFER);
          }
      }

    if (!PDU_view)
    {
    /* put the catalog application in the buffer */
    attr_row = PDUfind_attr_in_buffer(loc_attr, PDU_NFM_CATALOG_NAME);
    if (attr_row != -1)
      {
        status = MEMwrite_data(loc_attr, "char(12)", (attr_row + 1), 
				(PDU_NFM_DATA_COL + 1));
        _pdm_status("MEMwrite_data", status);

        if (status != MEM_S_SUCCESS)
          {
          PDUfill_in_string(&PDU_message, "Error in writing data to buffer");
          return(PDM_E_WRITE_BUFFER);
          }
      }
     }

    /* put the catalog type in the buffer */
    if ((PDU_parm_cat) && (PDU_view))
    {
    attr_row = PDUfind_col_in_buffer(loc_data, PDU_NFM_CATALOG_TYPE);
    if (attr_row != -1)
      {
        status = MEMwrite_data(loc_data, "CID", 1, (attr_row + 1));
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

    /* put the catalog name from the catalog name form into the buffer */
    attr_row = PDUfind_col_in_buffer(loc_data, PDU_NFM_CATALOG_NAME);
    if (attr_row != -1)
      {
      status = MEMwrite_data(loc_data, refresh->rev_catalog, 1, (attr_row + 1));
      _pdm_status("MEMwrite_data", status);
      if (status != MEM_S_SUCCESS)
        {
        PDUfill_in_string(&PDU_message, "Error in writing data to buffer");
        return(PDM_E_WRITE_BUFFER);
        }
      }

    /* put the catalog description from the catalog name form into the buffer */
    attr_row = PDUfind_col_in_buffer(loc_data, PDU_NFM_CATALOG_DESC);
    if ((attr_row != -1) && (PDU_cat_description != NULL))
      {
      status = MEMwrite_data(loc_data, PDU_cat_description, 1, (attr_row + 1));
      _pdm_status("MEMwrite_data", status);
      if (status != MEM_S_SUCCESS)
        {
        PDUfill_in_string(&PDU_message, "Error in writing data to buffer");
        return(PDM_E_WRITE_BUFFER);
        }
      }

    /* put the ACL from the catalog name form into the buffer */
    attr_row = PDUfind_col_in_buffer(loc_data, PDU_NFM_ACL_NO);
    if (attr_row != -1) 
      {
      status = MEMwrite_data(loc_data, PDU_cat_aclno, 1, (attr_row + 1));
      _pdm_status("MEMwrite_data", status);
      if (status != MEM_S_SUCCESS)
        {
        PDUfill_in_string(&PDU_message, "Error in writing data to buffer");
        return(PDM_E_WRITE_BUFFER);
        }
      }

    /* if the static/dynamic attribute form has been displayed, the buffers
       were stored in global variables. Otherwise, get the buffers from PDM*/
       
      /* call NFMrtic_it to find ' in the data buffer */
      status1 = NFMRtic_it( loc_data );

      status1 = NFMRtic_it( cat_data );

      status1 = NFMRtic_it( dyn_data );

      status1 = NFMRtic_it( cat_attr );

      status1 = NFMRtic_it( dyn_attr );

      if ((PDM_debug_on) && (PDU_cat_func_bufr))
        MEMprint_buffer("Function buffer", PDU_cat_func_bufr, PDU_DEBUG_FILE);

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

      /* add the catalog to the PDM database */
      if ((!PDU_view) && (!PDU_parm_cat) && (status == PDM_S_SUCCESS))
      {
      status = PDMrcreate_catalog(loc_attr, loc_data, cat_attr,
                               cat_data, cat_list, PDU_dynamic_table,dyn_attr, 
                               dyn_data,dyn_list);
      _pdm_status("PDMrcreate_catalog", status );
      }
      else if ((status == PDM_S_SUCCESS) && (PDU_view))
      {
      PDUmessage(PDS_M_CREATE_CATALOG, 's');
      status = PDMcreate_view_catalog(loc_data, cat_attr, cat_data, cat_list, 
                                      PDU_dynamic_table, dyn_attr, dyn_data, 
                                      dyn_list);
      _pdm_status("PDMcreate_view_catalog", status);
      }
      else if ((PDU_parm_cat) && (status == PDM_S_SUCCESS))
      {
        PDUload_exec_structure("","","N", "", "","","",
                               0, 0);
      PDUmessage(PDS_M_CREATE_CATALOG, 's');
      status = PDMcreate_parametric_catalog(loc_attr, loc_data, cat_attr,
                               cat_data, cat_list, PDU_dynamic_table,dyn_attr, 
                               dyn_data,dyn_list);
                               
      _pdm_status("PDMrcreate_parametric_catalog", status );
      }

      if (status != PDM_S_SUCCESS)
        PDUfill_in_string(&PDU_message, "Could not create catalog");

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

      /* free up global variables */
      if (PDU_cat_aclno)
        PDUfill_in_string(&PDU_cat_aclno, NULL);

      if ((refresh->rev_catalog) && (strcmp(refresh->rev_catalog, "") != 0))
        PDUfill_in_string(&refresh->rev_catalog, NULL);

      if ((PDU_cat_description) && (strcmp(PDU_cat_description, "") != 0))
        PDUfill_in_string(&PDU_cat_description, NULL);

      if (cat_attr)
        MEMclose(&cat_attr);
      if (cat_data)
        MEMclose(&cat_data);
      if (cat_list)
        MEMclose(&cat_list);

    if (loc_attr)
      MEMclose(&loc_attr);
    if (loc_data)
      MEMclose(&loc_data);
    if (loc_list)
      MEMclose(&loc_list);

    PDU_loc_data = NULL;
    PDU_cat_atr = NULL;
    PDU_cat_data = NULL;
    PDU_cat_list = NULL;
    PDU_dyn_attr = NULL;
    PDU_dyn_data = NULL;
    PDU_dyn_list = NULL;

    refresh->status = status;
    return(status);
   }
