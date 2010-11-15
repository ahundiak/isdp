/* Do not alter this SPC information: $Revision: 1.3.3.1 $ */
/*
**	NAME:							rislang.h
**	AUTHORS:						Hitesh R. Patel
**	CREATION DATE:					5/93
**	ABSTRACT:
**			Macro to define default language.
**	
**	REVISION HISTORY:
*/

/*
**	DEFINES
*/
/* Default language to be initialized */
#if defined(unix) || defined(DOS_)
#define RIS_DEFAULT_LANGUAGE "english"
#endif
#if defined(WIN32)
#define RIS_DEFAULT_LANGUAGE NULL
#endif

#define CONFIG_FILE_NAME 	"langs"

#define RIS_LANGUAGE_ID 	1
#define RIS_LANGUAGE_NAME	2
#define RIS_LANGUAGE_DIR    	3
#define OS_LANGUAGE_ID 		4
#define CODE_PAGE 		5
#define OS_LANGUAGE_NAME	6

/*
**	TYPES
*/

/*
**	VARIABLES
*/
