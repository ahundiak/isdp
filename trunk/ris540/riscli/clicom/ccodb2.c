/*
**	NAME:							ccodb2.c
**	AUTHORS:						Sunil Murthy
**	CREATION DATE:					11/92
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
static char	*valid_db2_arch[] =
{
	"s370"
};
static int	valid_db2_arch_count = (sizeof(valid_db2_arch)/sizeof(char *));

static char *valid_db2_os[] =
{
	"mvs"
};
static int valid_db2_os_count = (sizeof(valid_db2_os)/sizeof(char *));

/* make sure there's an even number of entries. */
static char *valid_db2_env[] =
{
/* for lu6.2 */
	"cics",

/* for tcp */
	"native"
};
static int	valid_db2_env_count = (sizeof(valid_db2_env)/sizeof(char *));

static char *valid_db2_prot[] =
{
	"lu6.2",
	"tcp"
};
static int	valid_db2_prot_count = (sizeof(valid_db2_prot)/sizeof(char *));


/*
**      FUNCTION PROTOTYPES
*/
#define ccodb2_c
#include "ccodb2.prt"
#include "sys.prt"

/******************************************************************************/

/*
**	returns 1 for a valid arch otherwise returns 0
*/
extern int RIScco_valid_db2_arch(
	char	*arch)
{
	int		i;
	int 	ret = 0;

	for (i = 0; i < valid_db2_arch_count; i++)
	{
		if (!strcmp(arch, valid_db2_arch[i]))
		{
			ret = 1;
			break;
		}
	}
	return ret;			
}

/******************************************************************************/

/*
**	returns 1 for a valid os otherwise returns 0
*/
extern int RIScco_valid_db2_os(
	char	*os)
{
	int		i;
	int		ret = 0;

	for (i = 0; i < valid_db2_os_count; i++)
	{
		if (!strcmp(os, valid_db2_os[i]))
		{
			ret = 1;
			break;
		}
	}
	return ret;			
}

/******************************************************************************/

/*
**	returns 1 for a valid env, otherwise returns 0
*/
extern int RIScco_valid_db2_env(
	char	*env,
	char	*protocol)
{
	int		i;
	int		ret = 0;

	if (!strcmp(protocol, PROTOCOL_DEF_LU))
	{
		for (i = 0; i < valid_db2_env_count/2; i++)
		{
			if (!strcmp(env, valid_db2_env[i]))
			{
				ret = 1;
				break;
			}
		}
	}
	else if (!strcmp(protocol, PROTOCOL_DEF_TCP))
	{
		for (i = valid_db2_env_count/2; i < valid_db2_env_count; i++)
		{
			if (!strcmp(env, valid_db2_env[i]))
			{
				ret = 1;
				break;
			}
		}
	}
	return ret;			
}

/******************************************************************************/

/*
**	returns 1 for a valid protocol, otherwise returns 0
*/
extern int RIScco_valid_db2_net_protocol(
	char	*protocol)
{
	int		i;
	int 	ret = 0;

	for (i = 0; i < valid_db2_prot_count; i++)
	{
		if (!strcmp(protocol, valid_db2_prot[i]))
		{
			ret = 1;
			break;
		}
	}
	return ret;			
}

/******************************************************************************/
