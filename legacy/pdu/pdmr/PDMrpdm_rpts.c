/******************************************************************************
*                                                                             *
* Modifications:                                                              *
*                                                                             *
* 1. In the function PDMdelete_report section,the parameter bufr1 was replaced*
*    with pdm_bufr. This modification was done by Jamal Shakra on 8/15/1990.  * 
******************************************************************************/

#include <stdio.h>

#include "MEMstruct.h"
#include "PDMcommand.h"
#include "PDMmessage.h"
#include "PDUerror.h"
#include "PDUsts_st.h"
#include "PDUfile_def.h"
#include "MEMerrordef.h"
#include "MSGstruct.h"
#include "PDUproto.h"
#include "PDMproto.h"

static char s[1024];
static long status;
extern PDUsts_ptr PDUsts;
extern int PDMdebug_on;

/* This is for handling REPORTS debug on the requester side */

/* Function for validating report name 

   INPUT:	MEMptr		pdm_bufr;
	
			-> PDMopen_report_buffer(1,&pdm_bufr);
   OUPUT:
			PDM_S_SUCCESS    		If name is Unique
			PDM_E_REPORT_EXISTS		If name is already used
*/

int		PDMvalidate_report_name(report_name, templatetype)
char *report_name;
char *templatetype;
{
	PDMdebug("ENTER:PDMvalidate_report_name\n");
        _pdm_debug("report name = <%s>", report_name);
        _pdm_debug("templatetype = <%s>", templatetype);

	/* load exec structure */
	PDUload_exec_structure("","","","","",report_name,templatetype,0, 0);

	_pdm_debug("calling PDMsvalidate_report_name", 0);
	status = PDMsvalidate_report_name();
	_pdm_status("PDMsvalidate_report_name", status);

	PDMdebug("EXIT:PDMvalidate_report_name\n");
	return (status);
}


int	PDMread_report_format( catalog, partnum, revision, list_total, 
                               templatetype, process, where, templib, def_op, 
                               def_list)

char *catalog;
char *partnum;
char *revision;
int  list_total;
char *templatetype;
int  process;
char *where;
char *templib;
MEMptr *def_op;
MEMptr *def_list;
{
  MEMptr bufr1 = NULL;
  MEMptr bufr2 = NULL;
  int    status;

        _pdm_debug("In the function PDMread_report_format", 0);
         if ((catalog != NULL) && (strcmp(catalog, "") != 0))
          _pdm_debug("catalog = <%s>", catalog);
         if ((partnum != NULL) && (strcmp(partnum, "") != 0))
          _pdm_debug("partnum = <%s>", partnum);
         if ((revision != NULL) && (strcmp(revision, "") != 0))
          _pdm_debug("revision = <%s>", revision);
        _pdm_debug("list_total = <%d>", (char *)list_total);
         if ((templatetype != NULL) && (strcmp(templatetype, "") != 0))
          _pdm_debug("templatetype = <%s>", templatetype);
        _pdm_debug("process = <%d>", (char *)process);
         if ((where != NULL) && (strcmp(where, "") != 0))
          _pdm_debug("where = <%s>", where);
         if ((templib != NULL) && (strcmp(templib, "") != 0))
        _pdm_debug("templib = <%s>",templib);
        if (PDMdebug_on)
          {
          MEMprint_buffer("define options buffer", *def_op, PDU_DEBUG_FILE);
          MEMprint_buffer("define list buffer", *def_list, PDU_DEBUG_FILE);
          }
        
        status = MEMsplit_copy_buffer(*def_op, &bufr1,0);
        _pdm_status("MEMsplit_copy_buffer", status);

        status = MEMsplit_copy_buffer(*def_list, &bufr2,0);
        _pdm_status("MEMappend", status);

	/* load exec structure */
	PDUload_exec_structure("", catalog, partnum, revision, templatetype, 
                               "", "", process, list_total);

	_pdm_debug("calling PDMsread_report_format", 0);
	status = PDMsread_report_format(bufr1, bufr2, def_op, def_list);
	_pdm_status("PDMsread_report_format", status);

        if (PDMdebug_on)
                MEMprint_buffer ("PDMread_report_format: def_op",
                        *def_op, PDU_DEBUG_FILE);

        if (PDMdebug_on)
                MEMprint_buffer ("PDMread_report_formar: def_list",
                        *def_list, PDU_DEBUG_FILE);

	if (status != PDM_S_SUCCESS)
	  {
	  PDUmessage(status, 's');
	  return(status);
	  }
 
	PDMdebug("EXIT:PDMread_report_format\n");
	return(PDM_S_SUCCESS);
}

/*
	 This function is for adding a report on the server
	 the format is given in input buffers 

	INPUT:

	MEMptr		pdm_bufr; -> PDMopen_report_buffer(0,&pdm_bufr)

	The fifth column is n_addmod should be 
					('M' or 'm' or 'A' or 'a')

	MEMptr		16 - buffers

	OUTPUT:
				return codes
*/

int	PDMadd_report( catalog, partnum, revision, list_total, templatetype, 
                       process, where, templib, def_op, def_list)

char *catalog;
char *partnum;
char *revision;
int list_total;
char *templatetype;
int  process;
char *where;
char *templib;
MEMptr def_op;
MEMptr def_list;
{

        int             status;

	PDMdebug("ENTER:PDMadd_report\n");
        if ((catalog!= NULL) && (strcmp(catalog, "") != 0))
          _pdm_debug("Catalog = <%s>", catalog);
        if ((partnum!= NULL) && (strcmp(partnum, "") != 0))
          _pdm_debug("partnum = <%s>", partnum);
        if ((revision!= NULL) && (strcmp(revision, "") != 0))
          _pdm_debug("revision = <%s>", partnum);
        _pdm_debug("list_total = <%d>", (char *)list_total);
        if ((templatetype!= NULL) && (strcmp(templatetype, "") != 0))
          _pdm_debug("templatetype = <%s>", templatetype);
        _pdm_debug("process = <%d>", (char *)process);
        if ((where!= NULL) && (strcmp(where, "") != 0))
          _pdm_debug("where = <%s>", where);
        if ((templib!= NULL) && (strcmp(templib, "") != 0))
          _pdm_debug("templib = <%s>", templib);
        if (PDMdebug_on)
          {
          MEMprint_buffer("default options", def_op, PDU_DEBUG_FILE);
          MEMprint_buffer("default list", def_list, PDU_DEBUG_FILE);
          }

	/* load exec structure */
	PDUload_exec_structure("", catalog, partnum, revision, templatetype,
			       where, templib, process, list_total);

	_pdm_debug("calling PDMsadd_report", 0);
	status = PDMsadd_report(def_op, def_list);
	_pdm_status("PDMsadd_report", status);

	if (status != PDM_S_SUCCESS)
          {
	  PDUmessage(status, 's');
	  return(status);
          }

	PDMdebug("EXIT:PDMadd_report\n");
	return(status);
}

int	PDMdelete_report(report_name, templatetype)

	char*		report_name;
{

	PDMdebug("ENTER:PDMdelete_report\n");

	/* load exec structure */
	PDUload_exec_structure("",report_name, "", "", templatetype,"","",0, 0);

	_pdm_debug("calling PDMsdelete_report", 0);
	status = PDMsdelete_report();
	_pdm_status("PDMsdelete_report", status);

	if (status != PDM_S_SUCCESS)
          {
	  PDUmessage(status, 's');
	  return(status);
	  }

	PDMdebug("EXIT:PDMdelete_report\n");
	return(status);
}
	
int	PDMshow_boms(bom_list)
	MEMptr	*bom_list;
{
	PDMdebug("ENTER:PDMshow_boms\n");

        PDUmessage(PDS_M_SHOW_BOMS, 's');

	/* load exec structure */
	PDUload_exec_structure("","", "", "", "","","",0, 0);

	_pdm_debug("calling PDMsshow_boms", 0);
	status = PDMsshow_boms(bom_list);
	_pdm_status("PDMsshow_boms", status);

	if (status != PDM_S_SUCCESS)
	  {
	  PDUmessage(status, 's');
          return(status);
	  }

        PDUmessage(PDM_E_CLEAR_FIELD, 's');
	PDMdebug("EXIT:PDMshow_boms\n");
	return(PDM_S_SUCCESS);
}

int PDMgen_loc_report(template_name, saname, filename)

char *template_name;
char *saname;
char *filename;

  {
  MEMptr ret_bufr = NULL;
  char **data = NULL;
  int status;

  sprintf (s, "PDMgen_loc_report: template_name = <%s>\n", template_name);
  _pdm_debug(s, 0);
  sprintf (s, "PDMgen_loc_report: saname = <%s>\n", saname);
  _pdm_debug(s, 0);

  /* load exec structure */
  PDUload_exec_structure("","","","",filename,template_name,saname,0,0);

  _pdm_debug("calling PDMreport_of_loc", 0);
  status = PDMreport_of_loc(&ret_bufr);
  _pdm_status("PDMreport_of_loc", status);

  if (status != PDM_S_SUCCESS)
    {
    if(status != PDM_E_DBA_SINGLE && status != PDM_E_USER_NOT_LOGGED_IN)
    PDUmessage(status, 's');
    return(status);
    }

        if ((status = MEMbuild_array(ret_bufr))
                                != MEM_S_SUCCESS)
          {
                status = PDM_E_BUILD_ARRAY;
                return (status);
          }
    data = (char **) ret_bufr->data_ptr;
        if(ret_bufr->rows)
        {
                strcpy(filename,data[0]);
                MEMclose(&ret_bufr);
    }
        else
        {
                PDMdebug("bufr empty \n");
                return(PDM_E_FAILURE);
        }

     PDMdebug("PDMgen_loc_report: returning SUCCESS\n");
     return(PDM_S_SUCCESS);
  }

int PDMgen_parts_in_catalog(catalog, template_name, saname,filename)

char *catalog;
char *template_name;
char *saname;
char *filename;

  {
  MEMptr ret_bufr = NULL;
  char **data = NULL;
  int status;

  sprintf (s, "PDMgen_parts_in_catalog: catalog = <%s>\n", catalog);
  _pdm_debug(s, 0);
  sprintf (s, "PDMgen_parts_in_catalog: template_name = <%s>\n", template_name);
  _pdm_debug(s, 0);
  sprintf (s, "PDMgen_parts_in_catalog: saname = <%s>\n", saname);
  _pdm_debug(s, 0);

  /* load exec structure */
  PDUload_exec_structure("",catalog,"","",filename,template_name,saname,0,0);

  _pdm_debug("calling PDMreport_of_catalog", 0);
  status = PDMreport_of_catalog(&ret_bufr);
  _pdm_status("PDMreport_of_catalog", status);

  if (status != PDM_S_SUCCESS)
    {
    if(status != PDM_E_DBA_SINGLE && status != PDM_E_USER_NOT_LOGGED_IN)
    PDUmessage(status, 's');
    return(status);
    }

   if(PDMdebug_on)
     MEMprint_buffers("ret_bufr",ret_bufr,PDU_DEBUG_FILE);
   if ((status = MEMbuild_array(ret_bufr))
                                != MEM_S_SUCCESS)
          {
                status = PDM_E_BUILD_ARRAY;
                return (status);
          }
    data = (char **) ret_bufr->data_ptr;
        if(ret_bufr->rows == 1)
        {
        _pdm_debug("filename = <%s>", filename);
                strcpy(filename,data[0]);
        _pdm_debug("filename after strcpy= <%s>", filename);
                MEMclose(&ret_bufr);
    }
        else
        {
                PDMdebug("bufr empty \n");
                return(PDM_E_FAILURE);
        }

     PDMdebug("PDMgen_parts_in_catalog: returning SUCCESS\n");
     return(PDM_S_SUCCESS);
  }
