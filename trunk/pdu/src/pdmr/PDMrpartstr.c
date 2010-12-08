#include <stdio.h>


#include "MEMstruct.h"
#include <PDMcommand.h>
#include "PDUerror.h"
#include "PDUsts_st.h"
#include "MEMerrordef.h"
#include <PDMmessage.h>
#include "PDUfile_def.h"
#include "PDUproto.h"
#include "PDMproto.h"

static char s[1024];
extern PDUsts_ptr PDUsts;
extern int PDMdebug_on;

/*
	DESCRIPTION:
					Gets the first level children of the 
					part. Part has to be an assembly
    OUTPUT:
			 If successfull the child_buffer contains all 
		the children at first level. The format is as follows.

		char(14)		n_itemname
   		char(14)		n_itemrev
	   	char(1)			p_attached
   		char(10)		p_history
   		char(528)		p_orient
   		char(25)		p_quantity
   		char(20)		p_childno
   		char(25)		p_usageid
   		char(25)		p_viewid

    RETURN CODES:
	
	PDM_E_PART_NOT_FOUND
        PDM_E_CATALOG_NOT_FOUND
	PDM_E_BUILD_ARRAY
	PDM_E_PART_NOT_ASSEMBLY
	PDM_E_QUERY_SET_MEMBERS
	PDM_E_BUFFER_FORMAT
*/

int PDMget_children (catalog, n_itemname,
					 n_itemrev,child_buffer)
  char		*catalog;
  char		*n_itemname;
  char		*n_itemrev;
  MEMptr	*child_buffer;
  {
	sprintf (s, "PDMget_children: catalog = <%s>\n", catalog);
	_pdm_debug(s, 0);
	sprintf (s, "PDMget_children: part num = <%s>\n", n_itemname);
	_pdm_debug(s, 0);
	sprintf (s, "PDMget_children: revision = <%s>\n", n_itemrev);
	_pdm_debug(s, 0);

        /* Display Message */
        PDUmessage(PDS_M_GET_CHILDREN, 's');

        MEMprint_buffer("Child buffer",*child_buffer, PDU_DEBUG_FILE);

	/*  Send the command to PDM  */

/*
	if ((PDUsts->PDMrstatus = PDMsend_command 
			(PDM_GET_CHILDREN,"", catalog, n_itemname, n_itemrev, 
                        "", "", "",
			0, 0, NULL)) != PDM_S_SUCCESS)
	  {
		sprintf (s, "PDMget_children: PDMsend_command status = <%d>\n",
			PDUsts->PDMrstatus);
		_pdm_debug(s, 0);
		return (PDUsts->PDMrstatus);
	  }

	if ((PDUsts->PDMrstatus = PDMreceive_status 
					(child_buffer)) != PDM_S_SUCCESS)
	  {
		sprintf (s, "PDMget_children: PDMreceive_status status = <%d>\n",
			PDUsts->PDMrstatus);
		_pdm_debug(s, 0);
		return (PDUsts->PDMrstatus);
	  }
*/

        /* Display Message */
        PDUmessage(PDM_E_CLEAR_FIELD, 's');

	_pdm_debug ("PDMget_children: returning SUCCESS", 0);
	return (PDUsts->PDMrstatus);
  }

/*
	DESCRIPTION:
				 Lists saved views of the part in a buffer
    OUTPUT:
			 If successfull the view_buffer contains all 
		the saved views . The format is as follows.

		char(100)		p_origin
   		char(528)		p_rotation
	   	char(40)	 	p_viewname

    RETURN CODES:

	PDM_S_SUCCESS	   

	PDM_E_PART_NOT_FOUND
    PDM_E_CATALOG_NOT_FOUND
	PDM_E_BUILD_ARRAY
	
	PDM_E_NO_VIEWS_DEFINED		 
	PDM_E_VIEWS_TABLE_NOT_FOUND
*/

int PDMshow_saved_views (catalog, n_itemname,
					 n_itemrev,view_buffer)
  char		*catalog;
  char		*n_itemname;
  char		*n_itemrev;
  MEMptr	*view_buffer;
  {
  	int		status = PDM_S_SUCCESS;

	sprintf (s, "PDMshow_saved_views catalog = <%s>\n", catalog);
	_pdm_debug(s, 0);
	sprintf (s, "PDMshow_saved_views: part num = <%s>\n", n_itemname);
	_pdm_debug(s, 0);
	sprintf (s, "PDMshow_saved_views: revision = <%s>\n", n_itemrev);
	_pdm_debug(s, 0);

        /* Display Message */
        PDUmessage(PDS_M_SHOW_SAVED_VIEWS, 's');

	/* load exec structure */
	PDUload_exec_structure("", catalog,n_itemname,n_itemrev,"","","", 0,0);

	_pdm_debug("calling PDMsshow_saved_views", 0);
	status = PDMsshow_saved_views(view_buffer);
	_pdm_status("PDMsshow_saved_views", status);

	if (status != PDM_S_SUCCESS)
	  {
	  PDUmessage(status, 's');
	  return(status);
          }

         /* Display Message */
         PDUmessage(PDM_E_CLEAR_FIELD, 's');

	_pdm_debug ("PDMshow_saved_views: returning SUCCESS", 0);
	return (PDUsts->PDMrstatus);
  }

int PDMget_part_attach_info (
                             catalog,
                             n_itemname,
			     n_itemrev,
                             n_itemno,
                             view_buffer,
                             file_buffer
                            )
  char		*catalog;
  char		*n_itemname;
  char		*n_itemrev;
  int           n_itemno;
  MEMptr        *view_buffer;
  MEMptr	*file_buffer;
  {
   int		status = PDM_S_SUCCESS;

	sprintf (s, "PDMget_part_attach_info catalog = <%s>\n", catalog);
	_pdm_debug(s, 0);
	sprintf (s, "PDMget_part_attach_info part num = <%s>\n", n_itemname);
	_pdm_debug(s, 0);
	sprintf (s, "PDMget_part_attach_info revision = <%s>\n", n_itemrev);
	_pdm_debug(s, 0);
	sprintf (s, "PDMget_part_attach_info item no = %d\n", n_itemno);
	_pdm_debug(s, 0);

	/* load exec structure */
  	PDUload_exec_structure("", catalog, n_itemname, n_itemrev,
			       "","","",0, n_itemno);

  	_pdm_debug("calling PDMget_ems_files", 0);
  	status = PDMget_ems_files(view_buffer, file_buffer);
  	_pdm_status("PDMget_ems_files", status);

  	if (status != PDM_S_SUCCESS)
    	  {
	  MEMclose(view_buffer);
	  MEMclose(file_buffer);
    	  return(status);
    	  }

        if (PDMdebug_on)
	   {
           MEMprint_buffer("part attach info buffer",
                            *view_buffer, PDU_DEBUG_FILE);
           MEMprint_buffer("part attach info buffer",
                           *file_buffer, PDU_DEBUG_FILE);
	   }
           

	_pdm_debug ("PDMget_part_attach_info: returning SUCCESS", 0);
	return (status);
  }

int PDMget_part_view_list (
                           catalog,
                           n_itemname,
			   n_itemrev,
                           view_buffer
                          )
  char		*catalog;
  char		*n_itemname;
  char		*n_itemrev;
  MEMptr	*view_buffer;
  {
	int	status = PDM_S_SUCCESS;

	sprintf (s, "PDMget_part_view_list catalog = <%s>\n", catalog);
	_pdm_debug(s, 0);
	sprintf (s, "PDMget_part_view_list part num = <%s>\n", n_itemname);
	_pdm_debug(s, 0);
	sprintf (s, "PDMget_part_view_list revision = <%s>\n", n_itemrev);
	_pdm_debug(s, 0);

	/* load exec structure */
        PDUload_exec_structure("", catalog, n_itemname, n_itemrev,"","","",0,0);

        _pdm_debug("calling PDMget_saved_views", 0);
        status = PDMget_saved_views(view_buffer);
        _pdm_status("PDMget_saved_views", status);

        if (status != PDM_S_SUCCESS)
          {
          PDUmessage(status, 's');
          MEMclose(view_buffer);
          return(status);
          }

	_pdm_debug ("PDMget_part_view_list: returning SUCCESS", 0);
	return (status);
  }
