#include <stdio.h>
#include "MEMstruct.h"
#include "PDMcommand.h"
#include "PDUcommand.h"
#include "PDUerror.h"
#include "MEMerrordef.h"
#include "PDUfile_def.h"
#include "PDUproto.h"
#include "PDMproto.h"
#include "PDMmessage.h"


static char s[1024];
extern int PDMdebug_on;
extern int PDU_command;

int PDMopen_buffer(type,buffer)
int			type;
MEMptr		*buffer;
{
int             status = PDM_S_SUCCESS;
       
        _pdm_debug("In the PDMopen_buffer function", 0);

	switch(type)
	{
		case 1:
			status = MEMopen(buffer,1024);
			if(status != MEM_S_SUCCESS)
 		    {
				sprintf(s,"%s %s %d\n",
				"PDMopen_buffer: MEMopen ",
				"Failed status ",status);
				_pdm_debug(s, 0);
				return(PDM_E_OPEN_BUFFER);
			}
			status = MEMwrite_format
						(*buffer,"n_catalogname","char(30)");
			if(status != MEM_S_SUCCESS) goto cleanup;
			status = MEMwrite_format
						(*buffer,"n_itemname","char(30)");
			if(status != MEM_S_SUCCESS) goto cleanup;
			status = MEMwrite_format
						(*buffer,"n_itemrev","char(30)");
			if(status != MEM_S_SUCCESS) goto cleanup;
			status = MEMwrite_format
						(*buffer,"p_orient","char(528)");
			if(status != MEM_S_SUCCESS) goto cleanup;
			status = MEMwrite_format
						(*buffer,"p_quantity","char(25)");
			if(status != MEM_S_SUCCESS) goto cleanup;
			status = MEMwrite_format
						(*buffer,"p_history","char(10)");
			if(status != MEM_S_SUCCESS) goto cleanup;
			status = MEMwrite_format
						(*buffer,"p_childno","char(20)");
			if(status != MEM_S_SUCCESS) goto cleanup;
			status = MEMwrite_format
						(*buffer,"p_usageid","char(25)");
			if(status != MEM_S_SUCCESS) goto cleanup;
			status = MEMwrite_format
						(*buffer,"p_viewid","char(25)");
			if(status != MEM_S_SUCCESS) goto cleanup;

    /* begin BETH added the attributes p_tagno p_alttagno p_incbom p_explode */

			status = MEMwrite_format
						(*buffer,"p_tagno","integer");
			if(status != MEM_S_SUCCESS) goto cleanup;
			status = MEMwrite_format
						(*buffer,"p_alttagno","char(25)");
			if(status != MEM_S_SUCCESS) goto cleanup;
			status = MEMwrite_format
						(*buffer,"p_incbom","char(1)");
			if(status != MEM_S_SUCCESS) goto cleanup;
			status = MEMwrite_format
						(*buffer,"p_explode","char(1)");
			if(status != MEM_S_SUCCESS) goto cleanup;
/* end BETH */

			break;
		case 2:
			status = MEMopen(buffer,1024);
			if(status != MEM_S_SUCCESS)
 		    {
				sprintf(s,"%s %s %d\n",
				"PDMopen_buffer: MEMopen ",
				"Failed status ",status);
				_pdm_debug(s, 0);
				return(PDM_E_OPEN_BUFFER);
			}
			status = MEMwrite_format
                                        (*buffer,"n_catalogno","integer");
			if(status != MEM_S_SUCCESS) goto cleanup;
			status = MEMwrite_format
					(*buffer,"n_itemno","integer");
			if(status != MEM_S_SUCCESS) goto cleanup;

                        status = MEMwrite_format
                                         (*buffer,"n_cofilename","char(14)");
                        if(status != MEM_S_SUCCESS) goto cleanup;

			break;
		case 3:
			status = MEMopen(buffer,1024);
			if(status != MEM_S_SUCCESS)
 		    {
				sprintf(s,"%s %s %d\n",
				"PDMopen_buffer: MEMopen ",
				"Failed status ",status);
				_pdm_debug(s, 0);
				return(PDM_E_OPEN_BUFFER);
			}
			status = MEMwrite_format
						(*buffer,"p_origin","char(100)");
			if(status != MEM_S_SUCCESS) goto cleanup;
			status = MEMwrite_format
						(*buffer,"p_rotation","char(240)");
			if(status != MEM_S_SUCCESS) goto cleanup;
			status = MEMwrite_format
						(*buffer,"p_viewname","char(40)");
			if(status != MEM_S_SUCCESS) goto cleanup;
			break;
		case 4:
			status = MEMopen(buffer,1024);
			if(status != MEM_S_SUCCESS)
 		    {
				sprintf(s,"%s %s %d\n",
				"PDMopen_buffer: MEMopen ",
				"Failed status ",status);
				_pdm_debug(s, 0);
				return(PDM_E_OPEN_BUFFER);
			}
			status = MEMwrite_format
						(*buffer,"storage_no","integer");
			status = MEMwrite_format
						(*buffer,"storage_name","char(14)");
			if(status != MEM_S_SUCCESS) goto cleanup;
			status = MEMwrite_format
						(*buffer,"node_name","char(14)");
			if(status != MEM_S_SUCCESS) goto cleanup;
			status = MEMwrite_format
						(*buffer,"user_name","char(14)");
			if(status != MEM_S_SUCCESS) goto cleanup;
			status = MEMwrite_format
						(*buffer,"passwd","char(25)");
			if(status != MEM_S_SUCCESS) goto cleanup;
			status = MEMwrite_format
						(*buffer,"path_name","char(100)");
			if(status != MEM_S_SUCCESS) goto cleanup;
			break;
		case 5:
			status = MEMopen(buffer,1024);
			if(status != MEM_S_SUCCESS)
 		    {
				sprintf(s,"%s %s %d\n",
				"PDMopen_buffer: MEMopen ",
				"Failed status ",status);
				_pdm_debug(s, 0);
				return(PDM_E_OPEN_BUFFER);
			}
			status = MEMwrite_format
						(*buffer,"command","char(100)");
			if(status != MEM_S_SUCCESS) goto cleanup;
			status = MEMwrite_format
						(*buffer,"workflow_name","char(20)");
			if(status != MEM_S_SUCCESS) goto cleanup;
			status = MEMwrite_format
						(*buffer,"project_name","char(20)");
			if(status != MEM_S_SUCCESS) goto cleanup;
			status = MEMwrite_format
						(*buffer,"table_name","char(20)");
			if(status != MEM_S_SUCCESS) goto cleanup;
			break;

		case 6:
			status = MEMopen(buffer,1024);
			if(status != MEM_S_SUCCESS)
 		    {
				sprintf(s,"%s %s %d\n",
				"PDMopen_buffer: MEMopen ",
				"Failed status ",status);
				_pdm_debug(s, 0);
				return(PDM_E_OPEN_BUFFER);
			}
			status = MEMwrite_format
                                        (*buffer,"n_catalogno","integer");
			if(status != MEM_S_SUCCESS) goto cleanup;

			status = MEMwrite_format
					(*buffer,"n_itemno","integer");
			if(status != MEM_S_SUCCESS) goto cleanup;

		        status = MEMwrite_format
			 	         (*buffer,"n_catalogname","char(20)");
			if(status != MEM_S_SUCCESS) goto cleanup;

			status = MEMwrite_format
					 (*buffer,"n_itemname","char(40)");
			if(status != MEM_S_SUCCESS) goto cleanup;

			status = MEMwrite_format
				         (*buffer,"n_itemrev","char(40)");
			if(status != MEM_S_SUCCESS) goto cleanup;

			status = MEMwrite_format
				         (*buffer,"n_cofilename","char(14)");
			if(status != MEM_S_SUCCESS) goto cleanup;

			break;

                case 7:
                        status = MEMopen(buffer,1024);
                        if(status != MEM_S_SUCCESS)
                    {
                                sprintf(s,"%s %s %d\n",
                                "PDMopen_buffer: MEMopen ",
                                "Failed status ",status);
                                _pdm_debug(s, 0);
                                return(PDM_E_OPEN_BUFFER);
                        }
                        status = MEMwrite_format
                                        (*buffer,"n_catalogno","integer");
                        if(status != MEM_S_SUCCESS) goto cleanup;

                        status = MEMwrite_format
                                        (*buffer,"n_itemno","integer");
                        if(status != MEM_S_SUCCESS) goto cleanup;

                        status = MEMwrite_format
                                         (*buffer,"n_catalogname","char(20)");
                        if(status != MEM_S_SUCCESS) goto cleanup;

                        status = MEMwrite_format
                                         (*buffer,"n_itemname","char(40)");
                        if(status != MEM_S_SUCCESS) goto cleanup;

                        status = MEMwrite_format
                                         (*buffer,"n_itemrev","char(40)");
                        if(status != MEM_S_SUCCESS) goto cleanup;

                        status = MEMwrite_format
                                         (*buffer,"n_cofilename","char(14)");
                        if(status != MEM_S_SUCCESS) goto cleanup;

                        status = MEMwrite_format
                                         (*buffer,"n_action","char(20)");
                        if(status != MEM_S_SUCCESS) goto cleanup;

                        break;

                case 8:
                        status = MEMopen(buffer,512);
                        if(status != MEM_S_SUCCESS)
                          {
                                sprintf(s,"%s %s %d\n",
                                "PDMopen_buffer: MEMopen ",
                                "Failed status ",status);
                                _pdm_debug(s, 0);
                                return(PDM_E_OPEN_BUFFER);
                          }
                        status = MEMwrite_format
                                        (*buffer,"n_catalogname","char(20)");
                        if(status != MEM_S_SUCCESS) goto cleanup;

                        break;

                case 9:
                        status = MEMopen(buffer,1024);
                        if(status != MEM_S_SUCCESS)
                          {
                                sprintf(s,"%s %s %d\n",
                                "PDMopen_buffer: MEMopen ",
                                "Failed status ",status);
                                _pdm_debug(s, 0);
                                return(PDM_E_OPEN_BUFFER);
                          }
                        status = MEMwrite_format
                                         (*buffer,"n_itemname","char(40)");
                        if(status != MEM_S_SUCCESS) goto cleanup;

                        status = MEMwrite_format
                                         (*buffer,"n_itemrev","char(40)");
                        if(status != MEM_S_SUCCESS) goto cleanup;

                        status = MEMwrite_format
                                         (*buffer,"n_itemdesc","char(40)");
                        if(status != MEM_S_SUCCESS) goto cleanup;

                        status = MEMwrite_format
                                         (*buffer,"p_parttype","char(2)");
                        if(status != MEM_S_SUCCESS) goto cleanup;

                        break;
                 
                case 10:
                        status = MEMopen(buffer,512);
                        if(status != MEM_S_SUCCESS)
                          {
                                sprintf(s,"%s %s %d\n",
                                "PDMopen_buffer: MEMopen ",
                                "Failed status ",status);
                                _pdm_debug(s, 0);
                                return(PDM_E_OPEN_BUFFER);
                          }
                        status = MEMwrite_format
                                        (*buffer,"n_itemrev","char(40)");
                        if(status != MEM_S_SUCCESS) goto cleanup;

                        break;

                case 11:
                        status = MEMopen(buffer,512);
                        if(status != MEM_S_SUCCESS)
                          {
                                sprintf(s,"%s %s %d\n",
                                "PDMopen_buffer: MEMopen ",
                                "Failed status ",status);
                                _pdm_debug(s, 0);
                                return(PDM_E_OPEN_BUFFER);
                          }
                        status = MEMwrite_format
                                        (*buffer,"p_usageid","char(25)");
                        if(status != MEM_S_SUCCESS) goto cleanup;

                        break;

                case 12:
                        status = MEMopen(buffer,512);
                        if(status != MEM_S_SUCCESS)
                          {
                                sprintf(s,"%s %s %d\n",
                                "PDMopen_buffer: MEMopen ",
                                "Failed status ",status);
                                _pdm_debug(s, 0);
                                return(PDM_E_OPEN_BUFFER);
                          }
                        status = MEMwrite_format
                                        (*buffer,"n_cofilename","char(14)");
                        if(status != MEM_S_SUCCESS) goto cleanup;

                        break;

                case 13:
                        status = MEMopen(buffer,1024);
                        if(status != MEM_S_SUCCESS)
                          {
                                sprintf(s,"%s %s %d\n",
                                "PDMopen_buffer: MEMopen ",
                                "Failed status ",status);
                                _pdm_debug(s, 0);
                                return(PDM_E_OPEN_BUFFER);
                          }

                        status = MEMwrite_format
                                        (*buffer,"n_catalogno","integer");
                        if(status != MEM_S_SUCCESS) goto cleanup;
                        status = MEMwrite_format
                                        (*buffer,"n_itemno","integer");
                        if(status != MEM_S_SUCCESS) goto cleanup;

                        status = MEMwrite_format
                                         (*buffer,"n_catalogname","char(20)");
                        if(status != MEM_S_SUCCESS) goto cleanup;

                        status = MEMwrite_format
                                         (*buffer,"n_itemname","char(40)");
                        if(status != MEM_S_SUCCESS) goto cleanup;

                        status = MEMwrite_format
                                         (*buffer,"n_itemrev","char(40)");
                        if(status != MEM_S_SUCCESS) goto cleanup;

                        break;

		default:
				return(PDM_E_FAILURE);
	}
	return(PDM_S_SUCCESS);

 cleanup:
			MEMclose(buffer);
			sprintf(s,"%s %s %d\n",
			"PDMopen_buffer:MEMwrite_format ",
			"Failed status ", status);
			_pdm_debug(s, 0);
			return(status);
}

int PDMget_filenames(catalog, part, revision, buffer)
  char          *catalog;
  char          *part;
  char          *revision;
  MEMptr        *buffer;
  {

  long   status = PDM_S_SUCCESS;

  _pdm_debug("In the function PDMget_filenames",0);

  _pdm_debug("catalog = <%s>", catalog);
  _pdm_debug("part = <%s>", part);
  _pdm_debug("revision = <%s>", revision);

  /* Display Message */
  if (PDU_command != PDC_M_REVISE_ASSEMBLY)
    PDUmessage(PDS_M_GET_FILENAMES, 's');

  /* load PDUexec structure */
  PDUload_exec_structure("", catalog, part, revision, "","","",0, 0);

  _pdm_debug("calling PDMget_file_names", 0);
  status = PDMget_file_names(buffer);
  _pdm_status("PDMget_file_names", status);

  if (status != PDM_S_SUCCESS)
    return(status);
  
  if (PDMdebug_on)
    MEMprint_buffer("filename", *buffer, PDU_DEBUG_FILE);

  /* Display Message */
  PDUmessage(PDM_E_CLEAR_FIELD, 's');
  
  _pdm_debug ("PDMget_filenames: returning SUCCESS", 0);
  return (status);
  }  /* end PDMget_filenames */

int PDMrget_imm_parents(catalog, partid, revision, buffer)
char	*catalog;
char	*partid;
char	*revision;
MEMptr  *buffer;
{
	int     status = PDM_S_SUCCESS;

  	_pdm_debug("in the function PDMrget_imm_children", 0);

        sprintf (s,"PDMrget_cit_parents: catalog = <%s>\n", catalog);
        _pdm_debug (s, 0);
        sprintf (s,"PDMrget_cit_parents: partid = <%s>\n", partid);
        _pdm_debug (s, 0);
        sprintf (s,"PDMrget_cit_parents: revision = <%s>\n", revision);
        _pdm_debug (s, 0);

        /* Display Message */
        PDUmessage(PDS_M_CIT_PARENTS, 's');

        /* load exec structure */
        PDUload_exec_structure("", catalog, partid, revision, "","","", 0,0);

        _pdm_debug("calling PDMget_imm_parents", 0);
        status = PDMget_imm_parents(buffer);
        _pdm_status("PDMget_imm_parents", status);

/*
	if (status != PDM_S_SUCCESS)
          {
          PDUmessage(status, 's');
          return(status);
          }
*/

        /* Display Message */
        PDUmessage(PDM_E_CLEAR_FIELD, 's');

        _pdm_debug ("PDMrget_imm_parents: returning SUCCESS", 0);
        return (status);
}

