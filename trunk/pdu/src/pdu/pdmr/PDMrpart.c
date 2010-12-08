#include <stdio.h>

#include "MEMstruct.h"
#include "PDMcommand.h"
#include "PDUerror.h"
#include "PDUsts_st.h"
#include "MEMerrordef.h"
#include "NFMerrordef.h"
#include "PDUuser.h"
#include "PDUfile_def.h"
#include "NFMapi.h"
#include <PDMmessage.h>
#include "PDUstr.h"
#include "PDUproto.h"
#include "PDMproto.h"

#define TRUE  1
#define FALSE 0

static char s[1024];
extern PDUsts_ptr PDUsts;
extern int PDMdebug_on;
extern int change_files_flag;
extern struct PDUuser *user;
extern struct PDUrefresh    *refresh;

int PDMradd_part (project, catalog, partnum, rev, attribute_buffer, data_buffer,
                  add_buffer)

  char		*project;
  char		*catalog;
  char          *partnum;
  char          *rev;
  MEMptr	attribute_buffer;
  MEMptr	data_buffer;
  MEMptr        add_buffer;
  {
	int   status = PDM_S_SUCCESS;

	sprintf (s, "PDMradd_part: catalog = <%s>\n", catalog);
	_pdm_debug(s, 0);

	if (PDMdebug_on)
	  {
		MEMprint_buffer ("PDMradd_part: attribute_buffer", 
				attribute_buffer, PDU_DEBUG_FILE);
		MEMprint_buffer ("PDMradd_part: data_buffer", 
				data_buffer, PDU_DEBUG_FILE);
                MEMprint_buffer ("PDMradd_part: add_buffer",
                                 add_buffer, PDU_DEBUG_FILE);
	  }

        /* Display Message */
        PDUmessage(PDS_M_ADD_PART, 's');

	/* load PDMexec structure */
	PDUload_exec_structure(project, catalog, partnum, rev, "", "","",0, 0);

	_pdm_debug("calling PDMadd_part", 0);
	status = PDMadd_part(attribute_buffer, data_buffer, add_buffer);
	_pdm_status("PDMadd_part", status);

	if (status != PDM_S_SUCCESS)
          {
/*
          PDUmessage(status, 's');
	  MEMclose(&attribute_buffer);
	  MEMclose(&data_buffer);
          MEMclose(&add_buffer);
*/
          return(status);
          }

        /* Display Message */
        PDUmessage(PDM_E_CLEAR_FIELD, 's');

	_pdm_debug("PDMradd_part: returning SUCCESS", 0);
	return (status);
  }

int PDMrdelete_part (catalog,part_num,revision)
  char		*catalog;
  char		*part_num;
  char		*revision;
  {
	int     status = PDM_S_SUCCESS;

        _pdm_debug("In PDMdelete_part",0);

	sprintf (s, "PDMdelete_part: catalog = <%s>\n", catalog);
	_pdm_debug(s, 0);
	sprintf (s, "PDMdelete_part: part_num = <%s>\n", part_num);
	_pdm_debug(s, 0);
	sprintf (s, "PDMdelete_part: revision = <%s>\n", revision);
	_pdm_debug(s, 0);

        /* Display Message */
        PDUmessage(PDS_M_DELETE_PART, 's');

	/* load exec structure */
        PDUload_exec_structure("", catalog, part_num, revision, "","","", 0,0);

        _pdm_debug("calling PDMdelete_part", 0);
        status = PDMdelete_part();
        _pdm_status("PDM20delete_part", status);

        if (status != PDM_S_SUCCESS)
          {
          PDUmessage(status, 's');
          return(status);
          }

        /* Display Message */
        PDUmessage(PDM_E_CLEAR_FIELD, 's');

	_pdm_debug("PDMdelete_part: returning SUCCESS", 0);
	return (status);
  }


int PDMcheck_delete_part (catalog,part_num,revision)
  char		*catalog;
  char		*part_num;
  char		*revision;
  {
	int status = PDM_S_SUCCESS;

        _pdm_debug("In PDMcheck_delete_part",0);

	sprintf (s, "PDMcheck_delete_part: catalog = <%s>\n", catalog);
	_pdm_debug(s, 0);
	sprintf (s, "PDMcheck_delete_part: part_num = <%s>\n", part_num);
	_pdm_debug(s, 0);
	sprintf (s, "PDMcheck_delete_part: revision = <%s>\n", revision);
	_pdm_debug(s, 0);

        /* Display Message */
        PDUmessage(PDS_M_CHECK_DELETE_PART, 's');

	/* load exec structure */
	PDUload_exec_structure("", catalog, part_num, revision, "","","", 0,0);

	_pdm_debug("calling PDMscheck_delete_part", 0);
	status = PDMscheck_delete_part();
	_pdm_status("PDMscheck_delete_part", status);

	if (status != PDM_S_SUCCESS)
	  {
 	  PDUmessage(status, 's');
	  return(status);
          }

        /* Display Message */
        PDUmessage(PDM_E_CLEAR_FIELD, 's');

	_pdm_debug("PDMcheck_delete_part: returning SUCCESS", 0);
	return (status);
  }

int PDMrmodify_part (catalog, part, rev, operation,attribute_buffer,
                     data_buffer, file_bufr, add_bufr)

  char		*catalog;
  char          *part;
  char          *rev;
  int		operation;
  MEMptr	attribute_buffer;
  MEMptr	data_buffer;
  MEMptr        file_bufr;
  MEMptr        add_bufr;

  {
	int	status = PDM_S_SUCCESS;

	sprintf (s, "PDMmodify_part: catalog = <%s>\n", catalog);
	_pdm_debug(s, 0);
	if (PDMdebug_on)
	  {
		MEMprint_buffer ("PDMmodify_part: attribute_buffer", attribute_buffer, PDU_DEBUG_FILE);
		MEMprint_buffer ("PDMmodify_part: data_buffer", data_buffer, PDU_DEBUG_FILE);
		MEMprint_buffer ("PDMmodify_part: file_bufr", file_bufr, PDU_DEBUG_FILE);
		MEMprint_buffer ("PDMmodify_part: add_bufr", add_bufr, PDU_DEBUG_FILE);
	  }

        PDUmessage(PDS_M_MODIFY_PART, 's');

        if (change_files_flag == TRUE)
           {
           change_files_flag = FALSE;

	   /* load exec structure */
	   PDUload_exec_structure("", catalog, part, rev, "","CHANGE","",
                                  operation,NFM_CHANGE_FILE_INFORMATION);
           }
        else
           {
	   /* load exec structure */
	   PDUload_exec_structure("", catalog, part, rev, "","CHANGE","",
				  operation,NFM_CHANGE_FILE_INFORMATION);

           }

	   _pdm_debug("calling PDM20modify_part", 0);
	   status = PDM20modify_part(attribute_buffer, data_buffer,
				     file_bufr, add_bufr);
	   _pdm_status("PDM20modify_part", status);

           PDUmessage(PDM_E_CLEAR_FIELD, 's');

	   if (status != PDM_S_SUCCESS)
             {
             PDUmessage(status, 's');
             return(status);
             }

	_pdm_debug("PDMmodify_part: returning SUCCESS", 0);
	return (status);
  }

int PDMdelete_files (catalog, partnum, revision, file_bufr) 

  char          *catalog;
  char          *partnum;
  char          *revision;
  MEMptr        file_bufr;

  {
	int	status = PDM_S_SUCCESS;

        sprintf (s, "PDMdelete_files: catalog = <%s>\n", catalog);
        _pdm_debug(s, 0);

        if (PDMdebug_on)
           MEMprint_buffer("file_bufr inside PDMdelete_files",file_bufr,PDU_DEBUG_FILE);

	/* load exec structure */
	PDUload_exec_structure("",catalog,partnum,revision,"","","",0,0);

        PDUmessage(PDS_M_DELETE_FILES, 's');

	_pdm_debug("calling PDMdelete_files_from_part", 0);
	status = PDMdelete_files_from_part(file_bufr);
	_pdm_status("PDMdelete_files_from_part", status);

	if (status != PDM_S_SUCCESS)
	  {
 	  PDUmessage(status, 's');
	  return(status);
	  }

        PDUmessage(PDM_E_CLEAR_FIELD, 's');

        _pdm_debug("PDMdelete_files: returning SUCCESS", 0);
        return (status);
  }

int PDMcancel_modify_part (catalog, part_num, part_rev,
						 attr_bufr,data_bufr)
  char		*catalog;
  char		*part_num;
  char		*part_rev;
  MEMptr	attr_bufr;
  MEMptr	data_bufr;
  {
  int           status = PDM_S_SUCCESS;

	_pdm_debug("ENTER:PDMcancel_modify_part", 0);
	sprintf (s, "PDMcancel_modify__part: catalog = <%s>\n", catalog);
	_pdm_debug(s, 0);
	sprintf (s, "PDMcancel_modify_part: part_num = <%s>\n", part_num);
	_pdm_debug(s, 0);
	sprintf (s, "PDMcancel_modify_part: part_rev = <%s>\n", part_rev);
	_pdm_debug(s, 0);

        if (!data_bufr)
           MEMopen(&data_bufr,512);

        if (!attr_bufr)
           MEMopen(&attr_bufr,512);

        /* Display Message */
        PDUmessage(PDS_M_CANCEL_MODIFY_PART, 's');

	/* load exec structure */
	PDUload_exec_structure("", catalog, part_num, part_rev, "","","",0, 0);

	_pdm_debug("calling PDMscancel_modify_part", 0);
	status = PDMscancel_modify_part(attr_bufr, data_bufr);
	_pdm_status("PDMscancel_modify_part", status);

	if (status != PDM_S_SUCCESS)
          {
	  PDUmessage(status, 's');
          MEMclose(&attr_bufr);
          MEMclose(&data_bufr);
	  return(status);
          }

        /* Display Message */
        PDUmessage(PDM_E_CLEAR_FIELD, 's');

 	_pdm_debug("PDMcancel_modify_part: returning SUCCESS", 0);
	return (status);
  }

int PDMadd_part_to_project (attribute_buffer, data_buffer)
  MEMptr	attribute_buffer;
  MEMptr	data_buffer;
  {
  int           status = PDM_S_SUCCESS;

	_pdm_debug("ENTER:PDMadd_part_to_project", 0);
	if (PDMdebug_on)
	  {
		MEMprint_buffer ("PDMadd_part_to_project: attribute_buffer", 
					attribute_buffer,PDU_DEBUG_FILE);
		MEMprint_buffer ("PDMadd_part_to_project: data_buffer", 
					data_buffer, PDU_DEBUG_FILE);
	  }

        /* Display Message */
        PDUmessage(PDS_M_ADD_PART_TO_PROJECT, 's');

	/* load exec structure */
        PDUload_exec_structure(refresh->rev_project,refresh->rev_catalog, 
                               refresh->rev_partid, refresh->rev_revision, 
                               "","","",0, 0);

	_pdm_debug("calling PDMsadd_part_to_project", 0);
	status = PDMsadd_part_to_project(attribute_buffer, data_buffer);
	_pdm_status("PDMsadd_part_to_project", status);

        if (status == NFM_E_ITEM_LOCKED)
          status = PDM_E_LOCKED_PART_IN_PROJ;

	if (status != PDM_S_SUCCESS)
          {
          PDUmessage(status, 's');
          return(status);
          }

        /* Display Message */
        PDUmessage(PDM_E_CLEAR_FIELD, 's');

	_pdm_debug("EXIT:PDMadd_part_to_project", 0);
	return(status);
  }



  
/* This function is written to support the PDMcheck_if_checkedin function on the
   server side. 

   Author: Mychelle Joiner
   Date: 03/20/91
*/

/******************************************************************************

    DESCRIPTION:

      Checks to see if the part is checked in.

    OUTPUT:

      There are no output buffers expected.

    RETURN CODES:
	
      PDM_E_NOTCHECK_OUT           Part is checked in.
      PDM_E_NOTCHECK_IN            Part is not checked in.
      PDM_S_SUCCESS                Status unknown.
      PDM_E_PART_NOT_FOUND         Part not found.
      PDM_E_CATALOG_NOT_FOUND      Catalog not found.
      PDM_E_PART_CHECKED_OUT       Part checked out, maybe by another user.
      PDM_E_ASSEMBLY_CHECKED_OUT   Assembly checked out.
      PDM_E_MEMBER_CHECKED_OUT     Member of another assembly.
      PDM_E_NO_PART_FILE           Part checked out as a member of an assembly,
                                     but with no file.

******************************************************************************/

int PDMcheck_if_checkedin(catalog, n_itemname,n_itemrev)

  char		*catalog;
  char		*n_itemname;
  char		*n_itemrev;
  {
  	int status = PDM_S_SUCCESS;

  	_pdm_debug("in the function PDMcheck_if_checkedin", 0);

	sprintf (s, "PDMcheck_if_checkedin: catalog = <%s>\n", catalog);
	_pdm_debug(s, 0);
	sprintf (s, "PDMcheck_if_checkedin: part num = <%s>\n", n_itemname);
	_pdm_debug(s, 0);
	sprintf (s, "PDMcheck_if_checkedin: revision = <%s>\n", n_itemrev);
	_pdm_debug(s, 0);

        /* Display Message */
        PDUmessage(PDS_M_QUERY_PART_STATUS, 's');

        /* load exec structure */
        PDUload_exec_structure(user->username, catalog, n_itemname, n_itemrev,
                               "","","",0,0);

	_pdm_debug("calling PDMquery_part_status", 0);
        status = PDMquery_part_status();
        _pdm_status("PDMquery_part_status", 0);

	if (status != PDM_S_SUCCESS)
          {
          /*PDUmessage(status, 's');*/
          return(status);
          }

        PDUmessage(PDM_E_CLEAR_FIELD, 's');

	_pdm_debug("PDMcheck_if_checkedin: returning SUCCESS", 0);
	return (status);
  }
