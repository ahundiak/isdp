#ifndef RISRAP_H
#define RISRAP_H

#include <stdio.h>
#include "ris.h"

#if defined(unix)
#define RISRAP_FILENAME_FORMAT_VERSION4 "/usr/tmp/risrap%d"  /* %d - userid */
#define RISRAP_FILENAME_FORMAT          "/usr/tmp/ris_rap%d" /* %d - userid */
#define OUTPUT_COLON                    "OUTPUT:"
#define NO_DELAY_TIME                   "NO_DELAY_TIME"
#define NO_ELAPSED_TIME                 "NO_ELAPSED_TIME"
#define NO_COMMAND_TIME                 "NO_COMMAND_TIME"
#define NO_OVERWRITE_FILE               "NO_OVERWRITE_FILE"
#endif
#if defined(WIN32)
#define RISRAP_KEY                      "SOFTWARE\\Intergraph\\risrap"
#define OUTPUT_VALUE_NAME               "OUTPUT"
#define OUTPUT_VALUE_TYPE               REG_SZ
#define DELAY_VALUE_NAME                "DELAY_TIME"
#define DELAY_VALUE_TYPE                REG_DWORD
#define ELAPSED_VALUE_NAME              "ELAPSED_TIME"
#define ELAPSED_VALUE_TYPE              REG_DWORD
#define COMMAND_VALUE_NAME              "COMMAND_TIME"
#define COMMAND_VALUE_TYPE              REG_DWORD
#define OVERWRITE_VALUE_NAME    "OVERWRITE_FILE"
#define OVERWRITE_VALUE_TYPE    REG_DWORD
#endif
#if defined(DOS)
#define RISRAP_FILENAME_FORMAT_VERSION4 "c:\\risrap"
#define RISRAP_FILENAME_FORMAT          "c:\\ris_rap"
#define OUTPUT_COLON                    "OUTPUT:"
#define NO_DELAY_TIME                   "NO_DELAY_TIME"
#define NO_ELAPSED_TIME                 "NO_ELAPSED_TIME"
#define NO_COMMAND_TIME                 "NO_COMMAND_TIME"
#define NO_OVERWRITE_FILE               "NO_OVERWRITE_FILE"
#endif

typedef struct
{
  char  filename[256];
  char  delay_time;
  char  total_time;
  char  command_time;
  char  overwrite_file;
} ris_rap_options;

/* =====================================================================================
 * Pulled these in form a prt file
 */
#ifdef __cplusplus
extern "C" {
#endif

extern void RISrap_initialize()
;
extern void RISrap_print_input_sqlda(
	FILE  *fp,
	sqlda *input)
;
extern void RISrap_print_output_sqlda(
	FILE  *fp,
	sqlda *output)
;
extern void RISrap_print_describe_sqlda(
	FILE  *fp,
	sqlda *data)
;
extern void RISrap_print_test_sqlda(
	FILE  *fp,
	sqlda *input)
;
extern void RISrap_print_client_parms(
	FILE  		 *fp,
	client_parms *parms)
;
extern void RISrap_print_schema_file_parms(
	FILE  			  *fp,
	schema_file_parms *parms)
;
extern int RISrap_compare_fetch(
	int  	id,
	sqlda 	*output,
	int 	one_row_only)
;

#ifdef __cplusplus
}
#endif

#endif /* RISRAP_H */
