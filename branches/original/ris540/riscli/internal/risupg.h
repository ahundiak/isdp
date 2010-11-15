/*
**	NAME:							risutl.h
**	AUTHORS:						Terrence McIntyre
**	CREATION DATE:					4/93
**	ABSTRACT:
**	
**	REVISION HISTORY:
*/
#ifndef RISUPG_H
#define RISUPG_H
 
/*
**	INCLUDES
*/

/*
**	DEFINES
*/
#if defined(unix) || defined(WIN32)
#define PRINTF		printf 
#endif
#if defined(WIN32)
#define	UNLINK		_unlink
#else
#define	UNLINK		unlink
#endif
#if defined(unix)
#define MKDIR	mkdir
#elif defined(WIN32)
#define MKDIR 	_mkdir
#endif
#define STRING(s)				((s)?(s):"NULL")
#define MSG(x)					(char *)RIScom_umsg(x)

#define INIT_RIS_UMS_FILE		0x0001
#define INIT_NET_UMS_FILE		0x0004

/*
**	TYPES
*/
typedef struct debug_info_s
{
	char	*name;
	int		len;
	int		*flag;
} debug_info_s;

/*
**	VARIABLES
*/
#endif
