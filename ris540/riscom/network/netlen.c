/* Do not alter this SPC information: $Revision: 1.1.54.1 $ */
/*
**	NAME:							netlen.c
**	AUTHORS:						Terry McIntyre
**	CREATION DATE:					11/91
**	ABSTRACT:
**	
**	REVISION HISTORY:
*/
 
/*
**	INCLUDES
*/
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
#include "net_sys.prt"
#define netlen_c
#include "netlen.prt"

/*
**	VARIABLES
*/

/*
**	FUNCTIONS
*/

/******************************************************************************/

extern void NET_put_len(
	unsigned char		len_field[NET_LEN_FIELD_SIZE],
	int					len)
{
	int i;
	int j;
	int mask32;
	char mask8;

	NET_DBG(("NET_put_len(len_field:0x%x len:%d)\n", len_field, len));

	memset(len_field, 0, NET_LEN_FIELD_SIZE);
	for (i = 0; i < 32; i++)
	{
		mask32 = 1 << i;
		if (len & mask32)
		{
			j = i / 8;

			mask8 = (char)(1 << (i % 8));
			len_field[j] |= mask8;
		}
	}

	NET_DBG(("NET_put_len: complete\n"));
}

/******************************************************************************/

extern void NET_get_len(
	unsigned char		len_field[NET_LEN_FIELD_SIZE],
	int					*lenp)
{
	int i;
	int j;
	int len;
	int mask32;
	char mask8;

	NET_DBG(("NET_get_len(len_field:0x%x lenp:0x%x)\n", len_field, lenp));

	len = 0;
	for (i = 0; i < 32; i++)
	{
		j = i / 8;
		mask8 = (char)(1 << (i % 8));
		if (len_field[j] & mask8)
		{
			mask32 = 1 << i;
			len |= mask32;
		}
	}
	*lenp = len;

	NET_DBG(("NET_get_len: *lenp:%d\nNET_get_len:complete\n", *lenp));
}

/******************************************************************************/
