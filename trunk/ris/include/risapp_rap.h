/*
**	NAME:							rap.h
**	AUTHORS:						Terry McIntyre
**	CREATION DATE:					6/92
**	ABSTRACT:
**		Describes global variables for RIS rap.
**	
**	REVISION HISTORY:
*/
 
#ifndef RIS_RAP_H
#define RIS_RAP_H

#ifdef RAP_GLOBAL_DEFINE
# define RAP_EXTERN
# define RAP_INIT(value) = value
#else
# define RAP_EXTERN extern
# define RAP_INIT(value)
#endif

/*
**	INCLUDES
*/
#include <stdio.h>
#include <sys/types.h>
#if defined(unix)
#include <sys/times.h>
#endif
#if defined(DOS)
#include <sys/time.h>
#endif

#include "risrap.h"

/*
**	DEFINES
*/
#define RIS_RAP_OPTIONS_FILENAME	"/usr/tmp/risrap"

#if defined(unix)
#define TIMES() times(&RIS_RAP_buffer)
#endif
#if defined(WIN32) || defined(DOS)
#define TIMES() clock()
#endif

#define RISrap_init() \
if (!RIS_RAP_initialized) \
{ \
 RISXrap_initialize(); \
 if (RIS_RAP) \
 { \
 	RIS_RAP_time = TIMES(); \
 	RIS_RAP_start_time = RIS_RAP_time; \
 } \
 RIS_RAP_initialized = 1; \
}

#define RISrap_term() \
{ \
	if (RIS_RAP) \
	{ \
		RIScom_fclose(RIS_RAP); \
		RIS_RAP = NULL; \
	} \
	RIS_RAP_initialized = 0; \
}

#define RISrap_check_BEGIN() \
if (RIS_RAP && RIS_int_level == 1) \
{ 

#define RISrap_check_END() \
}

#define RISrap_enter_BEGIN() \
RISrap_init(); \
RISrap_check_BEGIN() \
 RIS_RAP_last_time = RIS_RAP_time; \
 RIS_RAP_time = TIMES(); \
 if (RIS_RAP_options.delay_time && RIS_RAP_time > RIS_RAP_last_time) \
 { \
  fprintf(RIS_RAP,"DELAY:\n"); \
  fprintf(RIS_RAP,"time:%d\n",RIS_RAP_time-RIS_RAP_last_time); \
  if (RIS_RAP_options.total_time) \
  { \
  	fprintf(RIS_RAP,"elapsed time:%d\n",RIS_RAP_time-RIS_RAP_start_time);\
  } \
  fprintf(RIS_RAP,"----------\n"); \
 } \
 if (RISint_debug) \
 { \
  RIScom_output_debug("RAP COMMAND:%d\n", RIS_RAP_command); \
 } \
 fprintf(RIS_RAP,"COMMAND:%d\n", RIS_RAP_command++);

#define RISrap_enter_END() \
 fflush(RIS_RAP); \
RISrap_check_END()

#define RISrap_return_BEGIN() \
RISrap_check_BEGIN() \
 RIS_RAP_last_time = RIS_RAP_time; \
 RIS_RAP_time = TIMES();

#define RISrap_return_END() \
 fprintf(RIS_RAP,"sqlcode:%d\n",SQLCODE); \
 if (RIS_RAP_options.command_time) \
 { \
  fprintf(RIS_RAP,"time:%d\n",RIS_RAP_time-RIS_RAP_last_time); \
 } \
 if (RIS_RAP_options.total_time) \
 { \
  fprintf(RIS_RAP,"elapsed time:%d\n",RIS_RAP_time-RIS_RAP_start_time); \
 } \
 fprintf(RIS_RAP,"----------\n"); \
 fflush(RIS_RAP); \
RISrap_check_END()

#define RISrap_return() \
RISrap_return_BEGIN(); \
RISrap_return_END();

/*
**	TYPES
*/

/*
**	VARIABLES
*/
RAP_EXTERN  FILE			       *RIS_RAP					RAP_INIT(NULL);
RAP_EXTERN  int					RIS_RAP_initialized			RAP_INIT(0);
RAP_EXTERN  clock_t				RIS_RAP_time				RAP_INIT(0);
RAP_EXTERN  clock_t				RIS_RAP_last_time			RAP_INIT(0);
RAP_EXTERN  clock_t				RIS_RAP_start_time			RAP_INIT(0);
RAP_EXTERN  unsigned int			RIS_RAP_command				RAP_INIT(1);
#if defined(unix)
RAP_EXTERN struct tms			RIS_RAP_buffer;
#endif
RAP_EXTERN  ris_rap_options		RIS_RAP_options;

/* =======================================================================
 * Prototypes
 */
extern void RISAPI RISXrap_initialize();

#endif /* RIS_RAP_H */
