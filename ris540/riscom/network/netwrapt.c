/*
**      NAME:                                                   netwrapt.c
**      AUTHORS:                                                Jin Jing 
**      CREATION DATE:                                  6/92
**      ABSTRACT:
**      
**      REVISION HISTORY:
*/
#define NO_NET_DBG
 
/*
**      INCLUDES
*/
#if defined(unix) || defined(vms) || defined(DOS)
#include <errno.h>
#endif

#if defined(DOS)
/* SK */
#include <stdio.h>
#include <string.h>
#include <sys/types.h>
#include <sys/time.h>
#include <errno.h>
#include <sys/stat.h>
#include "dostcpip.h"
#endif

#include "net.h"

/*
**      DEFINES
*/

/*
**      TYPES
*/

/*
**      FUNCTION PROTOTYPES
*/
#define netwrapt_c
#include "netwrapt.prt"
#include "net_wrap.prt"

/*
**      VARIABLES
*/

/*
**      FUNCTIONS
*/

/******************************************************************************/

#if defined(unix) || defined(vms) || defined(DOS)
extern struct hostent *NET_gethostbyname(
	char *name)
{
	struct hostent *status;

	NET_DBG(("NET_gethostbyname()\n"));
	do
	{
		if (errno == EINTR)
		{
			errno = 0;
		}
		if ((status = gethostbyname(name)) == NULL)
		{
			NET_DBG(("NET_gethostbyname: status:<%s> errno:%d\n",status,errno));
		}
	}
	while (status == NULL && errno == EINTR);

	NET_DBG(("NET_gethostbyname: complete\n"));
	return status;
}
#endif

/******************************************************************************/

#if defined(unix) || defined(vms) || defined(DOS)
extern int NET_gethostname(
	char *name,
	int len)
{
	int status;

	NET_DBG(("NET_gethostname()\n"));
	do
	{
		if (errno == EINTR)
		{
			errno = 0;
		}
		if ((status = gethostname(name, len)) == -1)
		{
			NET_DBG(("NET_gethostname: status:<%s> errno:%d\n",status,errno));
		}
	}
	while (status == -1 && errno == EINTR);

	NET_DBG(("NET_gethostname: complete\n"));
	return status;
}
#endif

/******************************************************************************/

#if defined(unix) || defined(DOS)
extern int NET_socket(
	int domain,
	int type,
	int protocol)
{
	int status;

	NET_DBG(("NET_socket()\n"));
	do
	{
		if ((status = socket(domain, type, protocol)) == -1)
		{
			NET_DBG(("NET_socket: status:%d errno:%d\n",status, errno));
		}
	}
	while (status == -1 && errno == EINTR);

	NET_DBG(("NET_socket: complete\n"));
	return status;
}
#endif

/******************************************************************************/
