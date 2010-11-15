/* Do not alter this SPC information: $Revision: 1.1.54.1 $ */
/*
**	NAME:							netwrapx.c
**	AUTHORS:						Jin Jing 
**	CREATION DATE:					6/92
**	ABSTRACT:
**	
**	REVISION HISTORY:
*/
#define NO_NET_DBG
 
/*
**	INCLUDES
*/
#include <errno.h>
#include "net.h"

/*
**	DEFINES
*/

/*
**	TYPES
*/

/*
**	FUNCTION PROTOTYPES
*/
#define netwrapx_c
#include "netwrapx.prt"
#include "net_wrap.prt"

/*
**	VARIABLES
*/

/*
**	FUNCTIONS
*/

/******************************************************************************/

#if defined(__clipper__) || defined(vms)
extern char *NET_sni_accept(
	long *st)
{
	char *status;

	NET_DBG(("NET_sni_accept()\n"));
	do
	{
		if (errno == EINTR)
		{
			errno = 0;
		}
		if ((status = sni_accept(st)) != NULL)
		{
			NET_DBG(("NET_sni_accept: status:<%s> errno:%d\n",status, errno));
		}
	}
	while (status != NULL && errno == EINTR);

	NET_DBG(("NET_sni_accept: complete\n"));
	return status;
}
#endif

/******************************************************************************/

#if defined(__clipper__) || defined(vms)
extern char *NET_sni_close(
	long *st)
{
	char *status;

	NET_DBG(("NET_sni_close()\n"));
	do
	{
		if (errno == EINTR)
		{
			errno = 0;
		}
		if ((status = sni_close(st)) != NULL)
		{
			NET_DBG(("NET_sni_close: status:<%s> errno:%d\n",status, errno));
		}
	}
	while (status != NULL && errno == EINTR);

	NET_DBG(("NET_sni_close: complete\n"));
	return status;
}
#endif

/******************************************************************************/

#if defined(__clipper__) || defined(vms)
extern char *NET_sni_connect(
	long *st,
	char *node,
	unsigned short snum,
	char *srv)
{
	char *status;

	NET_DBG(("NET_sni_connect()\n"));
	do
	{
		if (errno == EINTR)
		{
			errno = 0;
		}
		if ((status = sni_connect(st, node, snum, srv)) != NULL)
		{
			NET_DBG(("NET_sni_connect: status:<%s> errno:%d\n",status, errno));
		}
	}
	while (status != NULL && errno == EINTR);

	NET_DBG(("NET_sni_connect: complete\n"));
	return status;
}
#endif

/******************************************************************************/
