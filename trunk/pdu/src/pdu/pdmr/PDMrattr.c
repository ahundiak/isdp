#include <stdio.h>
#include "MEMstruct.h"
#include <PDMcommand.h>
#include "PDUerror.h"
#include "PDUsts_st.h"
#include "PDUfile_def.h"
#include "PDUstr.h"
#include "PDMmessage.h"
#include "PDMtypes.h"
#include "MEMerrordef.h"
#include <PDUproto.h>
#include <PDMproto.h>

static char s[1024];
extern PDUsts_ptr PDUsts;
extern int PDMdebug_on;
extern struct PDUrefresh *refresh;


int PDMget_table_attributes
(operation, entity, catalog, attribute_buffer, data_buffer, list_buffers)
  int		operation;         /*  i - Type of operation          */
  int		entity;            /*  i - Type of entity             */
  char		*catalog;          /*  i - NULL if it does not apply  */
  MEMptr	*attribute_buffer; /*  o - NULL if function fails     */
  MEMptr	*data_buffer;      /*  o - NULL if function fails     */
  MEMptr	*list_buffers;     /*  o - NULL if function fails     */

  {
   int  status = PDM_S_SUCCESS;

	sprintf (s, "PDMget_table_attributes: operation = <%d>\n", operation);
	_pdm_debug (s, 0);
	sprintf (s, "PDMget_table_attributes: entity = <%d>\n", entity);
	_pdm_debug (s, 0);

	if (catalog == NULL)
	  {
		_pdm_debug ("PDMget_table_attributes: catalog is NULL", 0);
	  }
	else
	  {
		sprintf (s, "PDMget_table_attributes: catalog = <%s>\n", catalog);
		_pdm_debug (s, 0);
	  }

	/*  Initialize the return buffers  */

	*attribute_buffer = NULL;
	*data_buffer = NULL;
	*list_buffers = NULL;

        /* Display Message */
        PDUmessage(PDS_M_GET_TABLE_ATTR, 's');

	/* load PDMexec structure */
        if (entity == PDM_PROJECT)
         {
         _pdm_debug("ENTITY is PDM_PROJECT", 0);
	 PDUload_exec_structure(refresh->rev_project, refresh->rev_catalog, 
                                refresh->rev_partid, refresh->rev_revision,
                                "","","",operation, entity);
         }
        else
	 PDUload_exec_structure("", catalog, "", "","","","",operation, entity);

	/* call PDM function */
	_pdm_debug("calling PDMsget_table_attributes", 0);
	status = PDMsget_table_attributes(attribute_buffer, data_buffer,
					  list_buffers);
	_pdm_status("PDMsget_table_attributes", status);

	if (status != PDM_S_SUCCESS)
	  {
	  PDUmessage(status, 's');
	  return(status);
	  }

	if (PDMdebug_on)
          {
		MEMprint_buffer ("PDMget_table_attributes: data_buffer",
			*data_buffer, PDU_DEBUG_FILE);
		MEMprint_buffers ("PDMget_table_attributes: list_buffers",
			*list_buffers, PDU_DEBUG_FILE);
          }

        /* Display Message */
        PDUmessage(PDM_E_CLEAR_FIELD, 's');

	_pdm_debug ("PDMget_table_attributes: returning SUCCESS", 0);
	return (status);
  }


int PDMget_table_data (operation, entity, catalog, part_num, revision,
attribute_buffer, data_buffer, list_buffers)
  int		operation;         /*  i - Type of operation          */
  int		entity;            /*  i - Type of entity             */
  char		*catalog;          /*  i - NULL if it does not apply  */
  char		*part_num;         /*  i - NULL if it does not apply  */
  char		*revision;         /*  i - NULL if it does not apply  */
  MEMptr	*attribute_buffer; /*  o - NULL if function fails     */
  MEMptr	*data_buffer;      /*  o - NULL if function fails     */
  MEMptr	*list_buffers;     /*  o - NULL if function fails     */

  {
   int  status = PDM_S_SUCCESS;

	sprintf (s, "PDMget_table_data: operation = <%d>\n", operation);
	_pdm_debug (s, 0);
	sprintf (s, "PDMget_table_data: entity = <%d>\n", entity);
	_pdm_debug (s, 0);

	if ((catalog == NULL) || (strcmp(catalog, "") == 0))
	  {
		_pdm_debug ("PDMget_table_data: catalog is NULL", 0);
	  }
	else
	  {
		sprintf (s, "PDMget_table_data: catalog = <%s>\n", catalog);
		_pdm_debug (s, 0);
	  }

	if ((part_num == NULL) || (strcmp(part_num, "") == 0))
	  {
		_pdm_debug ("PDMget_table_data: part_num is NULL", 0);
	  }
	else
	  {
		sprintf (s, "PDMget_table_data: part_num = <%s>\n", part_num);
		_pdm_debug (s, 0);
	  }

	if ((revision == NULL) || (strcmp(revision, "") == 0))
	  {
		_pdm_debug ("PDMget_table_data: revision is NULL", 0);
	  }
	else
	  {
		sprintf (s, "PDMget_table_data: revision = <%s>\n", revision);
		_pdm_debug (s, 0);
	  }

	/*  Initialize the return buffers  */

	*attribute_buffer = NULL;
	*data_buffer = NULL;
	*list_buffers = NULL;

        /* Display Message */
        PDUmessage(PDS_M_GET_TABLE_DATA, 's');

	/* load PDMexec structure */
	PDUload_exec_structure("", catalog, part_num, revision, "","","",
                               operation, entity);

	/* call PDM function */
	_pdm_debug("calling PDMsget_table_data", 0);
	status = PDMsget_table_data(attribute_buffer,data_buffer,list_buffers);
	_pdm_status("PDMsget_table_data", status);

	if (status != PDM_S_SUCCESS)
	  {
	  _pdm_debug ("PDMget_table_data: ", 0);
	  _pdm_debug ("PDM server software failed to get attribute data", 0);
 	  PDUmessage(status, 's');
	  return(status);
	  }

	if (PDMdebug_on)
          {
		MEMprint_buffer ("PDMget_table_data: data_buffer",
			*data_buffer, PDU_DEBUG_FILE);
		MEMprint_buffer ("PDMget_table_data: list_buffers",
			*list_buffers, PDU_DEBUG_FILE);
          }

        /* Display Message */
        PDUmessage(PDM_E_CLEAR_FIELD, 's');

	_pdm_debug ("PDMget_table_data: returning SUCCESS", 0);
	return (status);
  }

/*
   This function calls NFMquery_template_information on the 
   server and returns the buffers. 
	"template_type" is a valid server template defined prior to 
	this call. 
*/

/*
   Returns the attribute buffer of the table specified.
   For catalogs set table_type to "CATALOG".
*/

int PDMquery_table_definition(table_name,
							  table_type,
							  attribute_buffer)
  char		*table_name;
  char		*table_type;
  MEMptr	*attribute_buffer; /*  o - NULL if function fails     */
  {
  int           status = PDM_S_SUCCESS;

	/*  Initialize the return buffers  */

	*attribute_buffer = NULL;

        /* Display Message */
        PDUmessage(PDS_M_QUERY_TABLE_DEFINITION, 's');

	/* load exec structure */
  	PDUload_exec_structure("", table_name, table_type, "", "","","",0, 0);

  	_pdm_debug("calling PDMsquery_table_definition", 0);
  	status = PDMsquery_table_definition(attribute_buffer);
  	_pdm_status("PDMsquery_table_definition", status);

  	if (status != PDM_S_SUCCESS)
    	{
    	PDUmessage(status, 's');
    	return(status);
    	}

        /* Display Message */
        PDUmessage(PDM_E_CLEAR_FIELD, 's');

	_pdm_debug ("PDMquery_table_definition: returning SUCCESS", 0);
	return (status);
  }

int PDMquery_fast_table_definition(table_name, buffer)
  char          *table_name;
  MEMptr        *buffer;
  {
  int           status = PDM_S_SUCCESS;

  _pdm_debug("In the function PDMquery_fast_table_definition",0);
  _pdm_debug("table_name = <%s>", table_name);

  /* Display Message */
  PDUmessage(PDS_M_FAST_TABLE_DEFINITION, 's');

  /* load exec structure */
  PDUload_exec_structure("", table_name, "", "", "","","",0, 0);

  _pdm_debug("calling PDMfast_query_table_def", 0);
  status = PDMfast_query_table_def(buffer);
  _pdm_status("PDMfast_query_table_def", status);

  if (status != PDM_S_SUCCESS)
    {
    PDUmessage(status, 's');
    return(status);
    }

  if (PDMdebug_on)
    MEMprint_buffer("attribute buffer", *buffer, PDU_DEBUG_FILE);

  /* Display Message */
  PDUmessage(PDM_E_CLEAR_FIELD, 's');

  _pdm_debug ("PDMquery_fast_table_definition: returning SUCCESS", 0);
  return (status);
  }  /* end PDMquery_fast_table_definition */
