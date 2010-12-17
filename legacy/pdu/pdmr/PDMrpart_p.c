/* This function is added to provide support for parametrics by adding part
   type to the refresh structure. This function is intended to provide 
   serveces from the PDM side.
  
   Author: Jamal Shakra
   Date: 9/26/1990
*/

#include <stdio.h>

#include "MEMstruct.h"
#include "PDMcommand.h"
#include "PDUerror.h"
#include "MEMerrordef.h"
#include "PDUproto.h"
#include "PDMproto.h"

static char s[1024];
extern int PDMdebug_on;

/*
	DESCRIPTION:
					Gets part type given catalog,
                                        part number, and revision.
    OUTPUT:
			 If successfull the part_type_buffer contains  
                         the part type requested.

	   	char(1)			p_parttype

    RETURN CODES:
	
	PDM_E_PART_NOT_FOUND
        PDM_E_REQ_COLUMN_NOT_FOUND
        PDM_E_CATALOG_NOT_FOUND
	PDM_E_BUILD_ARRAY
        PDM_S_SUCCESS
*/

int PDMquery_part_type(catalog, n_itemname,
					 n_itemrev,part_type_buffer)
  char		*catalog;
  char		*n_itemname;
  char		*n_itemrev;
  MEMptr	*part_type_buffer;
  {
  int           status = PDM_S_SUCCESS;

	sprintf (s, "PDMquery_part_type: catalog = <%s>\n", catalog);
	_pdm_debug(s, 0);
	sprintf (s, "PDMquery_part_type: part num = <%s>\n", n_itemname);
	_pdm_debug(s, 0);
	sprintf (s, "PDMquery_part_type: revision = <%s>\n", n_itemrev);
	_pdm_debug(s, 0);

	/* load exec structure */
	PDUload_exec_structure("", catalog, n_itemname, n_itemrev,
			       "","","",0, 0);

	status = PDMsquery_part_type(part_type_buffer);
 	_pdm_status("PDMsquery_part_type", status);

	if (status != PDM_S_SUCCESS)
          {
          PDUmessage(status, 's');
	  return(status);
          }

	_pdm_debug ("PDMquery_part_type: returning SUCCESS", 0);
	return (status);
  }
/*
	DESCRIPTION:
					Changes part type given catalog,
                                        part number, and revision.
    OUTPUT:
			 If successfull the part_type_buffer contains  
                         the changed part type.

	   	char(1)			p_parttype

    RETURN CODES:
	
	PDM_E_PART_NOT_FOUND
        PDM_E_REQ_COLUMN_NOT_FOUND
        PDM_E_CATALOG_NOT_FOUND
	PDM_E_BUILD_ARRAY
        PDM_S_SUCCESS
*/

int PDMchange_part_type(catalog, n_itemname,
					 n_itemrev,part_type)
  char		*catalog;
  char		*n_itemname;
  char		*n_itemrev;
  char          *part_type;

  {
  MEMptr        part_type_buffer = NULL;
  char          datatype[30];
  int           l1;
  int           status = PDM_S_SUCCESS;
	sprintf (s, "PDMchange_part_type: catalog = <%s>\n", catalog);
	_pdm_debug(s, 0);
	sprintf (s, "PDMchange_part_type: part num = <%s>\n", n_itemname);
	_pdm_debug(s, 0);
	sprintf (s, "PDMchange_part_type: revision = <%s>\n", n_itemrev);
	_pdm_debug(s, 0);

	sprintf (s, "PDMchange_part_type: part_type = <%s>\n", part_type);
	_pdm_debug(s, 0);

	status	= MEMopen(&part_type_buffer,512);
	if(status != MEM_S_SUCCESS)
	{
		sprintf (s, "%s %d",
		"MEMopen failed status ",status);
		_pdm_debug(s, 0);
		status = PDM_E_OPEN_BUFFER;
		return(status);
	}
	if(part_type == NULL)
	{
			l1 = 0;
			sprintf(datatype,"char(%d)",5);	
	}
	else if(!strlen(part_type))
	{
			l1 = 0;
			sprintf(datatype,"char(%d)",5);	
	}
	     else
	     {
			l1 = strlen(part_type);
			sprintf(datatype,"char(%d)",l1);	
	     }


	status = MEMwrite_format(part_type_buffer,"part_type",datatype);
	if(status != MEM_S_SUCCESS)
	{
		MEMclose(&part_type_buffer);
		sprintf (s, "%s %d",
		"MEMwrite_format failed status ",status);
		_pdm_debug(s, 0);
		status = PDM_E_WRITE_FORMAT;
		return(status);
	}
	sprintf(s,"\1");
	status	= MEMwrite(part_type_buffer,s);
	if(status != MEM_S_SUCCESS)
	{
		MEMclose(&part_type_buffer);
		sprintf (s, "%s %d",
		"MEMwrite failed status ",status);
		_pdm_debug(s, 0);
		status = PDM_E_WRITE_ROW;
		return(status);
	}
	status = MEMbuild_array(part_type_buffer);
	if(status != MEM_S_SUCCESS)
	{
		MEMclose(&part_type_buffer);
		sprintf (s, "%s %d",
		"MEMbuild_array failed status ",status);
		_pdm_debug(s, 0);
		status = PDM_E_BUILD_ARRAY;
		return(status);
	}
        if(l1)
        {

		status= MEMwrite_data(part_type_buffer,part_type,1,1);
		if(status != MEM_S_SUCCESS)
		{
			MEMclose(&part_type_buffer);
			sprintf (s, "%s %d",
			"MEMwrite_data failed status ",status);
			_pdm_debug(s, 0);
			status = PDM_E_WRITE_COLUMN;
			return(status);
		}
	}

	/* load exec structure */
	PDUload_exec_structure("", catalog, n_itemname, n_itemrev,
			       "","","",0, 0);

	_pdm_debug("calling PDMchange_part_type", 0);
	status = PDMschange_part_type(part_type_buffer);
	_pdm_status("PDMschange_part_type", status);

	if (status != PDM_S_SUCCESS)
      	  {
	  PDUmessage(status, 's');
	  MEMclose(&part_type_buffer);
	  return(status);
          }

	 MEMclose(&part_type_buffer);
	_pdm_debug ("PDMchange_part_type: returning SUCCESS", 0);
	return (status);
  }
