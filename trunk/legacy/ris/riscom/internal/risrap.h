/* Do not alter this SPC information: $Revision: 1.2.29.1 $ */
/*
**      NAME:                                                   risrap.h
**      AUTHORS:                                                Terrence McIntyre
**      CREATION DATE:                                  2/93
**      ABSTRACT:
**      
**      REVISION HISTORY:
*/

#ifndef RISRAP_H
#define RISRAP_H
 
/*
**      INCLUDES
*/

/*
**      DEFINES
*/
#if defined(unix)
#define RISRAP_FILENAME_FORMAT_VERSION4	"/usr/tmp/risrap%d" /* %d - userid */
#define RISRAP_FILENAME_FORMAT  		"/usr/tmp/ris_rap%d" /* %d - userid */
#define OUTPUT_COLON					"OUTPUT:"
#define NO_DELAY_TIME					"NO_DELAY_TIME"
#define NO_ELAPSED_TIME					"NO_ELAPSED_TIME"
#define NO_COMMAND_TIME					"NO_COMMAND_TIME"
#define NO_OVERWRITE_FILE				"NO_OVERWRITE_FILE"
#endif
#if defined(WIN32)
#define RISRAP_KEY				"SOFTWARE\\Intergraph\\risrap"
#define OUTPUT_VALUE_NAME		"OUTPUT"
#define OUTPUT_VALUE_TYPE		REG_SZ
#define DELAY_VALUE_NAME		"DELAY_TIME"
#define DELAY_VALUE_TYPE		REG_DWORD
#define ELAPSED_VALUE_NAME		"ELAPSED_TIME"
#define ELAPSED_VALUE_TYPE		REG_DWORD
#define COMMAND_VALUE_NAME		"COMMAND_TIME"
#define COMMAND_VALUE_TYPE		REG_DWORD
#define OVERWRITE_VALUE_NAME	"OVERWRITE_FILE"
#define OVERWRITE_VALUE_TYPE	REG_DWORD
#endif
#if defined(DOS)
#define RISRAP_FILENAME_FORMAT_VERSION4	"c:\\risrap"
#define RISRAP_FILENAME_FORMAT			"c:\\ris_rap"
#define OUTPUT_COLON					"OUTPUT:"
#define NO_DELAY_TIME					"NO_DELAY_TIME"
#define NO_ELAPSED_TIME					"NO_ELAPSED_TIME"
#define NO_COMMAND_TIME					"NO_COMMAND_TIME"
#define NO_OVERWRITE_FILE				"NO_OVERWRITE_FILE"
#endif

/*
**      TYPES
*/

typedef struct
{
	char    filename[256];
	char    delay_time;
	char    total_time;
	char    command_time;
	char	overwrite_file;
} ris_rap_options;

/*
**      VARIABLES
*/
#endif /* RISRAP_H */
