#include <stdio.h>

#include "MEMstruct.h"
#include "PDMcommand.h"
#include "PDUerror.h"
#include "PDUproto.h"
#include "PDMproto.h"
#include "MEMerrordef.h"
#include "PDUfile_def.h"

static char s[1024];

/*
	DESCRIPTION: Function to validate the access of the user 
	before executing the command.
	
	INPUT:

	entity			depends on the command)
					 (defined in WFentity.h) 
	command			command string 
	workflow_name	pdm_workflow is the default PDM workflow 
					initialized during PDM init
	table_name		Name of the catalog if applicable
					else	empty string
	project_name	empty string
	
	OUTPUT:
			None

	RETURN CODES:  PDM_S_SUCCESS if access is valid
				   PDM_E_VALIDATE_ACCESS if invalid access
*/

int PDMvalidate_user_access (command,workflow_name,
	table_name,project_name,part_num,part_rev)
  char		*command;
  char		*workflow_name;
  char		*table_name;
  char		*project_name;
  char		*part_num;
  char		*part_rev;
  {
 	MEMptr	wf_buffer = NULL;
	char	p_catalog[20];
	char	p_project[30];
	char	p_workflow[40];
        int     status = PDM_S_SUCCESS;

	_pdm_debug("ENTER:PDMvalidate_user_access", 0);	

        if (!project_name)
          project_name = NULL_STRING;

        if ((part_num != NULL) && (strcmp(part_num, "") != 0))
          {
	  sprintf (s, "PDMvalidate_user_access: part_num = <%s>\n", part_num);
	  _pdm_debug(s, 0);
          }
	else
	  PDUfill_in_string(&part_num, "");
        if ((part_rev != NULL) && (strcmp(part_rev, "") != 0))
          {
	  sprintf (s, "PDMvalidate_user_access: revision = <%s>\n",part_rev);
	  _pdm_debug(s, 0);
          }
	else
	  PDUfill_in_string(&part_rev, "");
        if ((command != NULL) && (strcmp(command, "") != 0))
          {
	  sprintf (s, "PDMvalidate_user_access: command = <%s>\n", command);
	  _pdm_debug(s, 0);
          }
        if ((table_name != NULL) && (strcmp(table_name, "") != 0))
         {
	 sprintf (s, "PDMvalidate_user_access: table name = <%s>\n",table_name);
	 _pdm_debug(s, 0);
         }
        if ((project_name != NULL) && (strcmp(project_name, "") != 0))
         {
	 sprintf (s, "PDMvalidate_user_access: project name = <%s>\n", 
	          project_name);
	 _pdm_debug(s, 0);
         }
        if ((workflow_name != NULL) && (strcmp(workflow_name, "") != 0))
         {
	 sprintf (s, "PDMvalidate_user_access: workflow name = <%s>\n",
	          workflow_name);
	 _pdm_debug(s, 0);
         }

	if(table_name == NULL || !strlen(table_name))
	{
		strcpy(p_catalog,"");
	}
	else if(strlen(table_name))
	{
		strcpy(p_catalog,table_name);
	}
	if(project_name == NULL || !strlen(project_name))
	{
		strcpy(p_project,"");
	}
	else if(strlen(project_name))
	{
		strcpy(p_project,project_name);
	}
	if(workflow_name == NULL || !strlen(workflow_name))
	{
		strcpy(p_workflow,"");
	}
	else if(strlen(workflow_name))
	{
		strcpy(p_workflow,workflow_name);
	}

	status = PDMopen_buffer(5,&wf_buffer);
	if(status < 0)
	{
		sprintf(s,"%s %d \n",
		"PDMopen_buffer failed status ",status);
		_pdm_debug(s, 0);
		status = PDM_E_OPEN_BUFFER;
		return(status);
	}
	sprintf(s,"%s\1%s\1%s\1%s",
    command,p_workflow,p_project,p_catalog);

	status = MEMwrite(wf_buffer,s);
	if(status != MEM_S_SUCCESS)
	{
		MEMclose(&wf_buffer);
		sprintf(s,"%s %d \n",
		"MEMwrite failed status ",status);
		_pdm_debug(s, 0);
		status = PDM_E_WRITE_ROW;
		return(status);
	}

	/* load PDMexec structure */
	if (part_num)
	  _pdm_debug("part_num = <%s>", part_num);
	if (part_rev)
	  _pdm_debug("part_rev = <%s>", part_rev);

	PDUload_exec_structure(project_name,table_name, part_num,part_rev, "",
                               "","",0, 0);

	_pdm_debug("calling PDMsvalidate_user_access", 0);
	status = PDMsvalidate_user_access(wf_buffer);
	_pdm_status("PDMsvalidate_user_access", status);

	if (status != PDM_S_SUCCESS)
          {
	  return(status);
          }

	sprintf(s,"EXIT:PDMvalidate_user_access %d\n",status);
	_pdm_debug(s, 0);
	return (status);
  }

 /*
	DESCRIPTION: To be called after the execution of a command
	
	INPUT:
			error_no	 The PDM error code  --- if erorr 
						 else PDM_S_SUCCESS
			error_msg	 A string of char(80) indicating the 
						 reason (message string) for a failure
 						 or a success (if preferred)

   RETURN_CODES:  PDM_S_SUCCESS    if success
				  PDM_E_SET_TO_STATE if not successfull
 */

 int  PDMset_to_state(error_no,application,error_msg)
 int  error_no;
 char *application;
 char *error_msg;
 {
 	MEMptr	wf_buffer = NULL;
	int     status = PDM_S_SUCCESS;

	_pdm_debug("ENTER:PDMset_to_state", 0);	
	sprintf (s, "PDMset_to_state: error no = <%d>\n", error_no);
	_pdm_debug(s, 0);
	sprintf (s, "PDMset_to_state: application = <%s>\n", application);
	_pdm_debug(s, 0);
	sprintf (s, "PDMset_to_state: error msg = <%s>\n",error_msg);
	_pdm_debug(s, 0);

	status = MEMopen(&wf_buffer,512);
	if(status != MEM_S_SUCCESS)
	{
		sprintf(s,"%s %d \n",
		"MEMopen failed status ",status);
		_pdm_debug(s, 0);
		status = PDM_E_OPEN_BUFFER;
		return(status);
	}
	status = MEMwrite_format(wf_buffer,
					"error_no","integer");
	if(status != MEM_S_SUCCESS)
	{
		MEMclose(&wf_buffer);
		sprintf(s,"%s %d \n",
		"MEMwrite_format failed status ",status);
		_pdm_debug(s, 0);
		status = PDM_E_WRITE_FORMAT;
		return(status);
	}
	status = MEMwrite_format(wf_buffer,
					"application","char(20)");
	if(status != MEM_S_SUCCESS)
	{
		MEMclose(&wf_buffer);
		sprintf(s,"%s %d \n",
		"MEMwrite_format failed status ",status);
		_pdm_debug(s, 0);
		status = PDM_E_WRITE_FORMAT;
		return(status);
	}
	status = MEMwrite_format(wf_buffer,
					"error_msg","char(85)");
	if(status != MEM_S_SUCCESS)
	{
		MEMclose(&wf_buffer);
		sprintf(s,"%s %d \n",
		"MEMwrite_format failed status ",status);
		_pdm_debug(s, 0);
		status = PDM_E_WRITE_FORMAT;
		return(status);
	}
	sprintf(s,"%d\1%s\1%s",error_no,application,error_msg);
	status = MEMwrite(wf_buffer,s);
	if(status != MEM_S_SUCCESS)
	{
		MEMclose(&wf_buffer);
		sprintf(s,"%s %d \n",
		"MEMwrite failed status ",status);
		_pdm_debug(s, 0);
		status = PDM_E_WRITE_ROW;
		return(status);
	}

	/* load PDMexec structure */
	PDUload_exec_structure("","", "","","","","",0,0);

	/* call PDM function */
	_pdm_debug("calling PDMsset_to_state", 0);
	PDMsset_to_state(wf_buffer);
	_pdm_status("PDMsset_to_state", status);

        if (status == MEM_S_SUCCESS)
          status = PDM_S_SUCCESS;

	if (status != PDM_S_SUCCESS)
	  {
	  return(status);
          }	

	sprintf(s,"EXIT:PDMset_to_state %d\n",status);
	_pdm_debug(s, 0);
	return (status);
 }


 int  PDMrmake_transition(catalog,part,rev,attr_list,data_list)
 char  *catalog;
 char  *part;
 char  *rev;
 MEMptr	attr_list;
 MEMptr	data_list;
 {
 int    status = PDM_S_SUCCESS;

	_pdm_debug("ENTER:PDMrmake_transition", 0);	

	PDUload_exec_structure("",catalog,part,rev,"","","", 0, 0);

        if (PDMdebug_on)
          MEMprint_buffer("data_list", data_list, PDU_DEBUG_FILE);

        status = PDMmake_transition(attr_list, data_list);
        _pdm_status("PDMmake_transition", status);

        if (attr_list)
   	   MEMclose(&attr_list);
        if (data_list)
   	   MEMclose(&data_list);

	_pdm_debug("EXIT:PDMrmake_transition", 0);	

	return (status);
 }
