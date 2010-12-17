/* Do not alter this SPC information: $Revision: 1.1.56.1 $ */
/*
**	NAME:							client.h
**	AUTHORS:						Terry McIntyre
**	CREATION DATE:					8/91
**	ABSTRACT:
**	
**	REVISION HISTORY:
*/

#ifndef RIS_CLIENT_H
#define RIS_CLIENT_H
 
/*
**	INCLUDES
*/
#include "riscli.h"
#include "risdebug.h"
#include "ris_err.h"
#include "risstjmp.h"
#include "arch.h"
#include "net.h"

/*
**	DEFINES
*/

#define	NET_ERROR_CHECK(net, error) 						\
if (net->error_code != NET_SUCCESS) 						\
{ 															\
	LONGJMP(error); 										\
}

#endif
