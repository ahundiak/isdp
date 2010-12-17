/* Do not alter this SPC information: $Revision: 1.1.56.1 $ */
/*
**	NAME:							dict.h
**	AUTHORS:						Dave Buehmann
**	CREATION DATE:					3/88
**	ABSTRACT:
**		
**	
**	REVISION HISTORY:
*/
#ifndef DICT_EXTERN
# ifdef DICT_GLOBAL_DEFINE
#  define DICT_EXTERN
# else
#  define DICT_EXTERN extern
# endif
#endif

 
/*
**	INCLUDES
*/
#include "riscli.h"
#include "riscl_pa.h"
#include "risdebug.h"
#include "ris_err.h"
#include "rishshtb.h"
#include "rislimit.h"
#include "risstjmp.h"

/*
**	DEFINES
*/
#define CREATE_SCHEMA 1
#define GRANT_REVOKE  2


/*
**	TYPES
*/
typedef struct hashwork
{
	struct hashnode	*hashp;
	struct hashwork	*next;
	int		hashval;
	int		action;
} hashwork;

/*
**	VARIABLES
*/
DICT_EXTERN int		 		RISdic_tab_hash_count;
DICT_EXTERN struct hashwork	*RISdic_hashwork[RIS_MAX_STMTS];
