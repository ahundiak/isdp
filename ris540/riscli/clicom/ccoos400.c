/*
**	NAME:							ccoos400.c
**	AUTHORS:						James Chang	
**	CREATION DATE:					12/93
**	ABSTRACT:
**		
**	
**	REVISION HISTORY:
*/
 
/*
**	INCLUDES
*/
#include "riscli.h"


/*
**	DEFINES
*/

/*
**	VARIABLES
*/

/*
**	FUNCTIONS
*/

static char *valid_os400_os[] =
{
	"os400",
	"OS400"
};
static int valid_os400_os_count = (sizeof(valid_os400_os)/sizeof(char *));

static char *valid_os400_prot[] =
{
	"appc",
	"APPC"
};
static int	valid_os400_prot_count = (sizeof(valid_os400_prot)/sizeof(char *));


/*
**      FUNCTION PROTOTYPES
*/
#define ccoos400_c
#include "ccoos400.prt"
#include "sys.prt"

/******************************************************************************/

/*
**	returns 1 for a valid os otherwise returns 0
*/
extern int RIScco_valid_os400_os(
	char	*os)
{
	int		i;
	int		ret = 0;

	for (i = 0; i < valid_os400_os_count; i++)
	{
		if (!strcmp(os, valid_os400_os[i]))
		{
			ret = 1;
			break;
		}
	}
	return ret;			
}


/******************************************************************************/

/*
**	returns 1 for a valid protocol, otherwise returns 0
*/
extern int RIScco_valid_os400_net_protocol(
	char	*protocol)
{
	int		i;
	int 	ret = 0;

	for (i = 0; i < valid_os400_prot_count; i++)
	{
		if (!strcmp(protocol, valid_os400_prot[i]))
		{
			ret = 1;
			break;
		}
	}
	return ret;			
}

/******************************************************************************/
