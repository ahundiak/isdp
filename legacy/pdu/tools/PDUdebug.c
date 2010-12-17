#include	<stdio.h>
#include	<PDUstr.h>
#include	<PDUerror.h>
#include	<PDUproto.h>

int PDUdebug_on()

/******************************************************************************

Doc:	PDUdebug_on

Abstract:
	Toggles the PDM debug to on.

Return Status:
	PDM_S_SUCCESS	-	Successful completion

History:
	9/13/89	-	Documentation date
*****************************************************************************/

  {
  int		status = PDM_S_SUCCESS;

  status = PDUdebug_on_off(1);
  return(status);
  }

int PDUdebug_off()

/******************************************************************************

Doc:	PDUdebug_off

Abstract:
	Toggles the PDM debug to off.

Return Status:
	PDM_S_SUCCESS	-	Successful completion

History:
	9/13/89	-	Documentation date

*****************************************************************************/

  {
  int		status = PDM_S_SUCCESS;

  status = PDUdebug_on_off(0);
  return(status);
  }
