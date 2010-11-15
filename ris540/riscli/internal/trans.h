/* Do not alter this SPC information: $Revision: 1.1.56.1 $ */
/*
**	NAME:							trans.h
**	AUTHORS:						David Michal
**	CREATION DATE:					03/23/88
**	ABSTRACT:
**		This file is included in all translator routines.
**	
**	REVISION HISTORY:
*/

#ifdef TRANS_GLOBAL_DEFINE
# define TRANS_EXTERN
# define TRANS_INITIAL(value) = value
#else
# define TRANS_EXTERN extern
# define TRANS_INITIAL(value)
#endif

/*
**	INCLUDES
*/
#include "riscl_pa.h"
#include "risdebug.h"
#include "risstjmp.h"
#include "ristoken.h"
#include "ris_err.h"

/*
**	DEFINES
*/
#define TRN_ERR_RETURN(error,pos)	\
{									\
	RIS_ERRPOS = pos;				\
	LONGJMP(error);					\
}

#define RIS_VIEW_OK 0x1
#define SYS_VIEW_OK 0x2

#define NOT_DEFAULT_USER_SEARCH 1

/*
**	TYPES
*/

/*
**	VARIABLES
*/

TRANS_EXTERN int		RIStrn_parm_index;
TRANS_EXTERN int		RIStrn_pos_targ_type;
TRANS_EXTERN ristree	*RIStrn_parm_list;
TRANS_EXTERN ristree	*RIStrn_real_list;
TRANS_EXTERN ristree	*RIStrn_int_list;
TRANS_EXTERN ristree	*RIStrn_smallint_list;
TRANS_EXTERN ristree	*RIStrn_decimal_list;
TRANS_EXTERN ristree	*RIStrn_between_ptr;
