#include <stdio.h>
#include "MEMstruct.h"
#include <PDMcommand.h>
#include "PDUerror.h"
#include "PDUsts_st.h"
#include "PDUfile_def.h"
#include "MEMerrordef.h"
#include <PDMmessage.h>
#include <PDUproto.h>
#include <PDMproto.h>

static char s[1024];
extern PDUsts_ptr PDUsts;
extern int PDMdebug_on;
extern char *PDU_auto_file_gen;

int PDMrcreate_catalog
(loc_buffer, loc_data, catalog_buffer, catalog_data, catalog_lists,
                       dynamic_table,dyn_attr, dyn_data,dyn_list)
  MEMptr	loc_buffer;
  MEMptr	loc_data;
  MEMptr	catalog_buffer;
  MEMptr	catalog_data;
  MEMptr	catalog_lists;
  char          *dynamic_table;
  MEMptr        dyn_attr;
  MEMptr        dyn_data;
  MEMptr        dyn_list;
  {

  int           no_buffers = 1;
  int           status = PDM_S_SUCCESS;

        _pdm_debug("In the function PDMrcreate_catalog",0);

	if (PDMdebug_on)
	  {
		MEMprint_buffer ("PDMrcreate_catalog: loc_buffer", loc_buffer, 
                                 PDU_DEBUG_FILE);
		MEMprint_buffer ("PDMrcreate_catalog: loc_data", loc_data, 
                                 PDU_DEBUG_FILE);
		MEMprint_buffer ("PDMrcreate_catalog: catalog_buffer", catalog_buffer,
			         PDU_DEBUG_FILE);
	       MEMprint_buffer ("PDMrcreate_catalog: catalog_data", catalog_data,
                                 PDU_DEBUG_FILE);
		MEMprint_buffer ("PDMrcreate_catalog: catalog_lists", catalog_lists,
			          PDU_DEBUG_FILE);
		MEMprint_buffer ("PDMrcreate_catalog: dyn_attr",
                                  dyn_attr,PDU_DEBUG_FILE);
                MEMprint_buffer ("PDMrcreate_catalog: dyn_data",
                                  dyn_data,PDU_DEBUG_FILE);
                MEMprint_buffer ("PDMrcreate_catalog: dyn_list",
                                  dyn_list,PDU_DEBUG_FILE);
	  }

        /* Display Message */
        PDUmessage(PDS_M_CREATE_CATALOG, 's');

	if (loc_buffer == NULL) MEMopen(&loc_buffer, 512);
	if (loc_data == NULL) MEMopen(&loc_data, 512);
	if (catalog_buffer == NULL) MEMopen(&catalog_buffer, 512);
	if (catalog_data == NULL) MEMopen(&catalog_data, 512);
	if (catalog_lists == NULL) MEMopen(&catalog_lists, 512);
	if (dyn_attr == NULL) MEMopen(&dyn_attr, 512);
	if (dyn_data == NULL) MEMopen(&dyn_data, 512);
	if (dyn_list == NULL) MEMopen(&dyn_list, 512);

	/* call function to load exec structure */
        PDUload_exec_structure("","",PDU_auto_file_gen, "", "","","",
                               0, no_buffers);

	/* call PDM function */
	_pdm_debug("calling PDMcreate_catalog", 0);
        PDUdeactivate_stop_sign();
	status = PDMcreate_catalog(loc_buffer, loc_data, catalog_buffer, 
		 catalog_data, catalog_lists, dynamic_table, dyn_attr, 
                 dyn_data, dyn_list);
        _pdm_status("PDMcreate_catalog", status);
        PDUactivate_stop_sign();

 	if (status != PDM_S_SUCCESS)
          {
          PDUmessage(status, 's');
          return(status);
          }

        /* Display Message */
        PDUmessage(PDM_E_CLEAR_FIELD, 's');

	_pdm_debug ("PDMrcreate_catalog: returning SUCCESS", 0);
	return (status);
  }

int PDMrmodify_catalog (loc_buffer, loc_data, 
			catalog_buffer, catalog_data, catalog_lists,
                        dynamic_table, dyn_attr, dyn_data, dyn_list)
  MEMptr	loc_buffer;
  MEMptr	loc_data;
  MEMptr	catalog_buffer;
  MEMptr	catalog_data;
  MEMptr	catalog_lists;
  char          *dynamic_table;
  MEMptr        dyn_attr;
  MEMptr        dyn_data;
  MEMptr        dyn_list;
  {
       int      no_buffers = 1;
       int	status = PDM_S_SUCCESS;

	if (PDMdebug_on)
	  {
		MEMprint_buffer ("PDMrmodify_catalog: loc_buffer", loc_buffer, 
                                 PDU_DEBUG_FILE);
		MEMprint_buffer ("PDMrmodify_catalog: loc_data", loc_data, 
                                 PDU_DEBUG_FILE);
		MEMprint_buffer ("PDMrmodify_catalog: catalog_buffer", catalog_buffer,
			         PDU_DEBUG_FILE);
	       MEMprint_buffer ("PDMrmodify_catalog: catalog_data", catalog_data,
                                PDU_DEBUG_FILE);
		MEMprint_buffer ("PDMrmodify_catalog: catalog_lists", catalog_lists,
                                 PDU_DEBUG_FILE);
		MEMprint_buffer ("PDMrmodify_catalog: dyn_attr", dyn_attr,
                                 PDU_DEBUG_FILE);
		MEMprint_buffer ("PDMrmodify_catalog: dyn_data", dyn_data,
                                 PDU_DEBUG_FILE);
		MEMprint_buffer ("PDMrmodify_catalog: dyn_list", dyn_list,
                                 PDU_DEBUG_FILE);
                
	  }

        /* Display Message */
        PDUmessage(PDS_M_MODIFY_CATALOG, 's');

	if (loc_buffer == NULL) MEMopen(&loc_buffer, 512);
	if (loc_data == NULL) MEMopen(&loc_data, 512);
	if (catalog_buffer == NULL) MEMopen(&catalog_buffer, 512);
	if (catalog_data == NULL) MEMopen(&catalog_data, 512);
	if (catalog_lists == NULL) MEMopen(&catalog_lists, 512);
	/*if (dyn_attr == NULL) MEMopen(&dyn_attr, 512);
	if (dyn_data == NULL) MEMopen(&dyn_data, 512);
	if (dyn_list == NULL) MEMopen(&dyn_list, 512);*/

	/* call function to load exec structure */
        PDUload_exec_structure("","",PDU_auto_file_gen, "", "","","",
                               0, no_buffers);

        /* call PDM function */
	_pdm_debug("calling PDMmodify_catalog", 0);
        PDUdeactivate_stop_sign();
        status = PDMmodify_catalog(loc_buffer, loc_data, catalog_buffer,
                 catalog_data, catalog_lists, dynamic_table, 
                 dyn_attr, dyn_data, dyn_list);
        _pdm_status("PDMmodify_catalog", status);
        PDUactivate_stop_sign();

        if (status != PDM_S_SUCCESS)
          {
          PDUmessage(status, 's');
          return(status);
          }

        /* Display Message */
        PDUmessage(PDM_E_CLEAR_FIELD, 's');

	_pdm_debug ("PDMrmodify_catalog: returning SUCCESS", 0);
	return (status);
  }


int PDMrdelete_catalog (catalog)
  char	*catalog;
  {
  int   status = PDM_S_SUCCESS;

	sprintf (s, "PDMrdelete_catalog: catalog = <%s>\n", catalog);
	_pdm_debug (s, 0);

        /* Display Message */
        PDUmessage(PDS_M_DELETE_CATALOG, 's');

	/* load the PDMexec structure */
	PDUload_exec_structure("",catalog,"","","","","",0,0);

	_pdm_debug("calling PDMdelete_catalog", 0);
        PDUdeactivate_stop_sign();
	status = PDMdelete_catalog();
        _pdm_status("PDMdelete_catalog", status);
        PDUactivate_stop_sign();

	if (status != PDM_S_SUCCESS)
          {
          PDUmessage(status, 's');
	  return(status);
          }

        /* Display Message */
        PDUmessage(PDM_E_CLEAR_FIELD, 's');

	_pdm_debug ("PDMrdelete_catalog: returning SUCCESS", 0);
	return (status);
  }

int PDMcatalog_acls(acl_buffer)

  MEMptr	*acl_buffer;
  {

  int status = PDM_S_SUCCESS;

  _pdm_debug("in the function PDUcatalog_acls", 0);

  /* Display Message */
  /* load exec structure */
  PDUload_exec_structure("","", "", "", "","","", 0, 0);

  /* call PDM function */
  _pdm_debug("calling PDMshow_catalog_acls", 0);
  status = PDMshow_catalog_acls(acl_buffer);
  _pdm_status("PDMshow_catalog_acls", status);

  if (status != PDM_S_SUCCESS)
    {
    PDUmessage(status, 's');
    return(status);
    }

	if (PDMdebug_on)
	  MEMprint_buffer("acl buffer", *acl_buffer, PDU_DEBUG_FILE);

        /* Display Message */
	_pdm_debug ("PDMcatalog_acls: returning SUCCESS", 0);
	return (status);
  }

int PDMget_dynamic_attributes(catalog,
                           dynamic_attrs_buffer, dynamic_data_buffer,
                           dynamic_list_buffer)
  char		*catalog;
  MEMptr        *dynamic_attrs_buffer;
  MEMptr        *dynamic_data_buffer;
  MEMptr        *dynamic_list_buffer;
  {
  long          status = PDM_S_SUCCESS;

        _pdm_debug("In the function PDMget_dynamic_attributes",0);
	sprintf (s, "%s %s %s\n",
	"PDMget_dynamic_attributes: ",	"catalog -> ",catalog);
	_pdm_debug(s, 0);

       /* Display Message */
       PDUmessage(PDS_M_GET_DYNAMIC_ATTR, 's');

	/* load PDMexec structure */
	PDUload_exec_structure("", catalog, "","","","","",0, 0);

	/* call PDM function */
        _pdm_debug("calling PDMquery_dynamic_table_information", 0);
	status = PDMquery_dynamic_table_information(dynamic_attrs_buffer,
		   dynamic_data_buffer, dynamic_list_buffer);
	_pdm_status("PDMquery_dynamic_table_information", status);

	if (status != PDM_S_SUCCESS)
	  return(status);

        if (PDMdebug_on)
           MEMprint_buffer ("PDMget_dynamic_attributes: dynamic_attrs_buffer",
                   *dynamic_attrs_buffer,PDU_DEBUG_FILE);

	if ((*dynamic_attrs_buffer)->rows == 0)
	  {
		MEMclose(dynamic_attrs_buffer);
		*dynamic_attrs_buffer = NULL;
	  }
		
          _pdm_debug("print dynamic_data_buffer",0);
            if (PDMdebug_on)
              MEMprint_buffer ("PDMquery_dynamic_attrs: dynamic_data_buffer",
                   *dynamic_data_buffer,PDU_DEBUG_FILE);

	if ((*dynamic_data_buffer)->rows == 0)
	  {
		MEMclose(dynamic_attrs_buffer);
		*dynamic_attrs_buffer = NULL;
	  }
		
          _pdm_debug("print dynamic_list_buffer",0);
            if (PDMdebug_on)
              MEMprint_buffer ("PDMquery_dynamic_attrs: dynamic_list_buffer",
                   *dynamic_list_buffer,PDU_DEBUG_FILE);

        if ((dynamic_attrs_buffer == NULL) && (dynamic_data_buffer == NULL) &&
	    (dynamic_list_buffer == NULL))
          {
    	  _pdm_debug("return_buffer is NULL",0);
    	  return (PDM_E_NULL_BUFFER);
          }

        /* DIsplay Message */

	_pdm_debug ("PDMquery_dynamic_attrs: returning SUCCESS", 0);
	return (status);
  }
