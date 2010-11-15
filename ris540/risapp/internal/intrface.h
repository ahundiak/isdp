/* Do not alter this SPC information: $Revision: 1.1.57.1 $ */
/*
**	NAME:							interface.h
**	AUTHORS:						David Michal
**	CREATION DATE:					4/87
**	ABSTRACT:
**	
**	REVISION HISTORY:
*/
 
#ifndef RIS_INTERFACE_H
#define RIS_INTERFACE_H

#ifdef INT_GLOBAL_DEFINE
# define INT_EXTERN
# define INT_INIT(value) = value
#else
# define INT_EXTERN extern
# define INT_INIT(value)
#endif

/*
**	INCLUDES
*/
#include "risapi.h"
#include "risapp.h"
#include "risdebug.h"
#include "ris_err.h"
#include "rismem.h"
#include "risstjmp.h"
#include "rap.h"

/*
**	DEFINES
*/
#define RIS_ENTER() \
{ \
 RIS_int_level++; \
}

#define RIS_RETURN() \
{ \
 if (RIS_int_level > 0) \
  RIS_int_level--; \
 else \
  RIS_int_level = 0; \
 return; \
}

#define RIS_CLEAR_ERROR() \
{ \
 SQLCODE = RIS_SUCCESS; \
 memset(risca, 0, sizeof(rissqlca)); \
 memset(dbca, 0, sizeof(rissqlca)); \
 risca->sqlstmt = RIS_risstmt; \
 dbca->sqlstmt = RIS_dbstmt; /* added by TDM 1/12/94 */ \
 RIS_risstmt[0] = '\0'; \
 RIS_dbstmt[0] = '\0'; \
}

#define SET_RISCA(err) \
{ \
 SQLCODE = (long)err; \
 risca->sqlcode = (long)err; \
 if (risca->sqlstmt && RIS_stmt && RIS_stmt->query) \
 { \
  strcpy(risca->sqlstmt, RIS_stmt->query); \
 } \
 if (err != RIS_SUCCESS) \
 { \
  risca->sqlerrm.sqlerrml = \
	(short)RISXint_error_msg(err, risca->sqlerrm.sqlerrmc,RIS_error_name); \
 } \
}

/*
**	TYPES
*/

/*
**	VARIABLES
*/
INT_EXTERN  char	RIS_error_name[RIS_MAX_ERROR_NAME]	INT_INIT("");
INT_EXTERN  int	RIS_int_level						INT_INIT(0);

#endif /* RIS_INTERFACE_H */
