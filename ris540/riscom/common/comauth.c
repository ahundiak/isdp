/* Do not alter this SPC information: $Revision: 1.1.55.1 $ */
/*
**	NAME:							comauth.c
**	AUTHORS:						Dave Buehmann
**	CREATION DATE:					4/90
**	ABSTRACT:
**		
**	
**	REVISION HISTORY:
*/
 
/*
**	INCLUDES
*/
#include "riscom.h"
#include "risdebug.h"

/*
**	DEFINES
*/

/*
**	TYPES
*/

/*
**	FUNCTION PROTOTYPES
*/
#define comauth_c
#include "comisfn.prt"
#include "comauth.prt"
#include "comdebug.prt"
#include "sys.prt"

/*
**	VARIABLES
*/

/*
**	FUNCTIONS
*/

/******************************************************************************/

extern void RIScom_init_auth(
	char *current)
{
	int i;

	for (i=0;i < ACC_SIZE;i++)
	{
		current[i] = '-';
	}
	current[i] = '\0';
}

/******************************************************************************/

extern void RIScom_make_grantable(
	char *current)
{
	int i;

	for (i=0;i < ACC_SIZE;i++)
	{
		if (RIScom_islower(current[i]))
		{
			current[i] = (char)(RIScom_toupper(current[i]));
		}
	}
}

/******************************************************************************/

#define INTERSECT_AUTH(current, auth, type)						\
{	if (current[type] != '-')									\
	{															\
		if (auth[type] == '-')									\
		{														\
			current[type] = '-';									\
		}														\
		else if (RIScom_isupper(current[type]) && RIScom_islower(auth[type]))	\
		{														\
			current[type] = auth[type];							\
		}														\
	}															\
}

/******************************************************************************/

extern void RIScom_intersect_auth(
	char *current,
	char *auth)
{
	INTERSECT_AUTH(current, auth, ACC_SELECT);
	INTERSECT_AUTH(current, auth, ACC_INSERT);
	INTERSECT_AUTH(current, auth, ACC_DELETE);
	INTERSECT_AUTH(current, auth, ACC_UPDATE);
	INTERSECT_AUTH(current, auth, ACC_CONNECT);
	INTERSECT_AUTH(current, auth, ACC_RESOURCE);
	INTERSECT_AUTH(current, auth, ACC_DBA);
}

/******************************************************************************/

extern int RIScom_has_auth(
	char *current,
	char *auth)
{
	if ((! auth) || (!*auth)) return(1);

	COM_DBG(("RIScom_has_auth: current <%s>; auth <%s>\n", current, auth));

	if (strcmp(auth,ANY_ACCESS) == 0)
	{
		if (current[ACC_SELECT] != '-' ||
			current[ACC_INSERT] != '-' ||
			current[ACC_DELETE] != '-' ||
			current[ACC_UPDATE] != '-')
			return (1);
		return(0);
	}

	if ((auth[ACC_SELECT] == 's' && current[ACC_SELECT] == '-') ||
		(auth[ACC_SELECT] == 'S' && current[ACC_SELECT] != 'S')) return(0);
	if ((auth[ACC_INSERT] == 'i' && current[ACC_INSERT] == '-') ||
		(auth[ACC_INSERT] == 'I' && current[ACC_INSERT] != 'I')) return(0);
	if ((auth[ACC_DELETE] == 'd' && current[ACC_DELETE] == '-') ||
		(auth[ACC_DELETE] == 'D' && current[ACC_DELETE] != 'D')) return(0);
	if ((auth[ACC_UPDATE] == 'u' && current[ACC_UPDATE] == '-') ||
		(auth[ACC_UPDATE] == 'U' && current[ACC_UPDATE] != 'U')) return(0);

	if ((auth[ACC_CONNECT] == 'c' && current[ACC_CONNECT] == '-') ||
		(auth[ACC_CONNECT] == 'C' && current[ACC_CONNECT] != 'C')) return(0);

	if ((auth[ACC_RESOURCE] == 'r' && current[ACC_RESOURCE] == '-') ||
		(auth[ACC_RESOURCE] == 'R' && current[ACC_RESOURCE] != 'R')) return(0);

	if ((auth[ACC_DBA] == 'd' && current[ACC_DBA] == '-') ||
		(auth[ACC_DBA] == 'D' && current[ACC_DBA] != 'D')) return(0);

	return(1);
}

/******************************************************************************/

#define ADD_AUTH(current, auth, type)						\
{	if (auth[type] != '-')									\
	{														\
		if (current[type] == '-' || RIScom_islower(current[type]))	\
		{													\
			current[type] = auth[type];						\
		}													\
	}														\
}

/******************************************************************************/

extern void RIScom_add_auth(
	char *current,
	char *auth)
{
	ADD_AUTH(current, auth, ACC_SELECT);
	ADD_AUTH(current, auth, ACC_INSERT);
	ADD_AUTH(current, auth, ACC_DELETE);
	ADD_AUTH(current, auth, ACC_UPDATE);
	ADD_AUTH(current, auth, ACC_CONNECT);
	ADD_AUTH(current, auth, ACC_RESOURCE);
	ADD_AUTH(current, auth, ACC_DBA);
}

/******************************************************************************/

extern void RIScom_del_auth(
	char *current,
	char *auth)
{
	if (auth[ACC_SELECT] != '-') current[ACC_SELECT] = '-';
	if (auth[ACC_INSERT] != '-') current[ACC_INSERT] = '-';
	if (auth[ACC_DELETE] != '-') current[ACC_DELETE] = '-';
	if (auth[ACC_UPDATE] != '-') current[ACC_UPDATE] = '-';
	if (auth[ACC_CONNECT] != '-') current[ACC_CONNECT] = '-';
	if (auth[ACC_RESOURCE] != '-') current[ACC_RESOURCE] = '-';
	if (auth[ACC_DBA] != '-') current[ACC_DBA] = '-';
}

/******************************************************************************/

extern void RIScom_common_auth(
	char	*auth1,
	char	*auth2,
	char	*intersect_auth)
{
	
	int	i;
	
	COM_DBG(("RIScom_common_auth: auth1 <%s>; auth2 <%s> intersect_auth <%s>\n", 
				auth1, auth2, intersect_auth));

	for (i = ACC_SELECT; i <= ACC_UPDATE; i++)
	{
		if ((RIScom_islower(auth1[i]) && (auth2[i] != '-')) ||
			(RIScom_isupper(auth1[i]) && RIScom_isupper(auth2[i])))
		{
			intersect_auth[i] = auth1[i];
		}
	}

	COM_DBG(("intersect_auth = <%s>\n", intersect_auth);) 
}

/******************************************************************************/

extern void RIScom_auth_tobe_added(
	char *current,
	char *auth)
{
	int i;

	for (i = ACC_SELECT; i <= ACC_UPDATE; i++)
	{
		if ((RIScom_islower(auth[i]) && (current[i] != '-')) ||
			(RIScom_isupper(auth[i]) && RIScom_isupper(current[i])))									
		{														
			auth[i] = '-';
		}														
	}
}

/******************************************************************************/
