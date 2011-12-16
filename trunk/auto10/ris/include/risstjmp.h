/* Do not alter this SPC information: $Revision: 1.1.54.1 $ */
/*
**	NAME:							risstjmp.h
**	AUTHORS:						Terrence McIntyre
**	CREATION DATE:					10/92
**	ABSTRACT:
**	
**	REVISION HISTORY:
*/

#ifndef RISSTJMP_H
#define RISSTJMP_H
 
#ifndef COM_EXTERN
# ifdef COM_GLOBAL_DEFINE
#  define COM_EXTERN
# else
#  define COM_EXTERN extern
# endif
#endif

#ifndef COM_INITIAL
# ifdef COM_GLOBAL_DEFINE
#  define COM_INITIAL(value) = value
# else
#  define COM_INITIAL(value)
# endif
#endif

/*
**	INCLUDES
*/
#include <setjmp.h>

/*
**	DEFINES
*/
#define LONGJMP(st)		RIScom_longjmp(st, __FILE__, __LINE__)
#define RESETJMP()		RIScom_resetjmp(__FILE__, __LINE__)
#define SETJMP()		setjmp(*RIScom_setjmp(__FILE__, __LINE__))

/*
**	TYPES
*/

/*
**	VARIABLES
*/
COM_EXTERN  int			RIS_cnt									COM_INITIAL(-1);

#endif
