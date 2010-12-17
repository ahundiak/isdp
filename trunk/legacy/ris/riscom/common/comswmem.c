/* Do not alter this SPC information: $Revision: 1.1.55.1 $ */
/*
**	NAME:							comswmem.c
**	AUTHORS:						Prasad Challa
**	CREATION DATE:					6/92
**	ABSTRACT:
**		
**	
**	REVISION HISTORY:
*/
 
/*
**	INCLUDES
*/
#include "risdebug.h"
#include "rismem.h"

/*
**	DEFINES
*/

/*
**	VARIABLES
*/

/*
**	FUNCTIONS
*/

/*
**      FUNCTION PROTOTYPES
*/
#define comswmem_c
#include "comdebug.prt"
#include "comswmem.prt"

/******************************************************************************/

/*
** For redeclare superschema with swap option--we need to swap the low level
** memory allocated for the prepared statements on the involved schemas.
*/

extern void RIScom_swap_mem(
	int primary_id,
	int secondary_id)
{

	ris_alloc_info temp;

	COM_DBG(("RIScom_swap_mem(primary_id:%d secondary_id:%d)\n", 
		primary_id, secondary_id));

	temp = RIS_mem->statement[primary_id];
	RIS_mem->statement[primary_id] = RIS_mem->statement[secondary_id];
	RIS_mem->statement[secondary_id] = temp;

}

/******************************************************************************/
