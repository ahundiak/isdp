#include <stdio.h>
#include <tools.h>
#include <PDUcommand.h>
#include <PDUerror.h>
#include <FI.h>
#include <PDUstr.h>
#include <PDUproto.h>

/****************************************************************************/
/*                                                                          */
/*  Function:		PDUcommand_launcher                                 */
/*                                                                          */
/*  Description:	Launches the PDU command for the 2.0 PDU user       */
/*                      interface. Provides the same functionalities as the */
/*                      slic files in the old interface.                    */
/*                                                                          */
/*  Creation Date:	August 21, 1991                                     */
/*                                                                          */
/*  Author:		Jenny Brewer                                        */
/*                                                                          */
/****************************************************************************/

int PDUvalidate_access(command)
int command;
{
  int status = PDM_S_SUCCESS;
  _pdm_debug("command is %d", (char *)command);
  switch (command)
    {
    case PDC_M_CREATE_LIKE_CATALOG:
    case PDC_M_CREATE_CATALOG:
    case PDC_M_MODIFY_CATALOG:

    	_pdm_debug("Display command string in message strip", 0);
    	status = PDUmessage(command, 'c');
  	_pdm_status("PDUmessage", status);
  	if (status != PDM_S_SUCCESS)
       	  return(status);
        _pdm_debug("Verify user access", 0);
   	status = PDUmessage_trans(command, 'v');
  	if (status != PDM_S_SUCCESS)
    	  return (status);
        break;

    case PDC_M_CREATE_ELEMENT:
    	_pdm_debug("Display command string in message strip", 0);
    	status = PDUmessage(command, 'c');
  	_pdm_status("PDUmessage", status);
  	if (status != PDM_S_SUCCESS)
       	  return(status);
        _pdm_debug("Verify command", 0);
        _pdm_debug("Verify user access", 0);
   	status = PDUmessage_trans(command, 'v');
  	if (status != PDM_S_SUCCESS)
    	  return (status);
        break;
    case PDC_M_MODIFY_ELEMENT:
    	_pdm_debug("Display command string in message strip", 0);
    	status = PDUmessage(command, 'c');
  	_pdm_status("PDUmessage", status);
  	if (status != PDM_S_SUCCESS)
       	  return(status);
        _pdm_debug("Verify command", 0);
        _pdm_debug("Verify user access", 0);
   	status = PDUmessage_trans(command, 'v');
  	if (status != PDM_S_SUCCESS)
    	  return (status);
        break;
    case PDC_M_DELETE_ELEMENT:
    	_pdm_debug("Display command string in message strip", 0);
    	status = PDUmessage(command, 'c');
  	_pdm_status("PDUmessage", status);
  	if (status != PDM_S_SUCCESS)
       	  return(status);
        _pdm_debug("Verify command", 0);
        _pdm_debug("Verify user access", 0);
   	status = PDUmessage_trans(command, 'v');
  	if (status != PDM_S_SUCCESS)
    	  return (status);
        break;
   default:
       status = PDM_S_SUCCESS;
       break;
  }
  _pdm_debug("PDUvalidate_access returns success", 0);
  return(status);
}

