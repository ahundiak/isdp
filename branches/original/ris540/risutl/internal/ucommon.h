/* Do not alter this SPC information: $Revision: 1.1.54.1 $ */
/*
**	NAME:							ucommon.h
**	AUTHORS:						Dave Buehmann
**	CREATION DATE:					4/88
**	ABSTRACT:
**		
**	REVISION HISTORY:
**
**	Added variables for support of INTERNATIONALIZATION.  Rick
*/
 
#ifdef UCO_GLOBAL_DEFINE
# define UCO_EXTERN
# define UCO_INIT(value) = value
#else
# define UCO_EXTERN extern
# define UCO_INIT(value)
#endif

#if defined(WIN32)
#include <windows.h>
#include <wchar.h>
#include "comuni.prt"
#endif
/*
**	INCLUDES
*/
/*
**	DEFINES
*/
#ifdef NO_UCO_DBG
#define UCO_DBG(s)
#else
#define UCO_DBG(s)	if (RISuco_debug) {RIScom_output_debug s;}
#endif

#if defined(WIN32)
#define MULTITOWIDE           0
#define WIDETOMULTI           1
#define RIS_DEFAULT_SIZE    256
#define ISSPACE(c)          RIScom_iswspace((wint_t) c)
#define ISALPHA(c)          RIScom_iswalpha((wint_t) c)
#define ISASCII(c)          RIScom_iswascii((wint_t) c)
#define ISALNUM(c)          RIScom_iswalnum((wint_t) c)
#define ISDIGIT(c)          RIScom_iswdigit((wint_t) c)
#define ISPUNCT(c)          RIScom_iswpunct((wint_t) c)
#define ISUPPER(c)          RIScom_iswupper((wint_t) c)
#define ISLOWER(c)          RIScom_iswlower((wint_t) c)
#define TOLOWER(c)          RIScom_towlower((wint_t) c)
#define TOUPPER(c)          RIScom_towupper((wint_t) c)
#define WIDECHAR(a)         L##a
#else
#define ISSPACE(c) RIScom_isspace(c)
#define ISALPHA(c) RIScom_isalpha(c)
#define ISASCII(c) RIScom_isascii(c)
#define ISALNUM(c) RIScom_isalnum(c)
#define ISDIGIT(c) RIScom_isdigit(c)
#define ISPUNCT(c) RIScom_ispunct(c)
#define ISUPPER(c) RIScom_isupper(c)
#define ISLOWER(c) RIScom_islower(c)
#define TOLOWER(c) RIScom_tolower(c)
#define TOUPPER(c) RIScom_toupper(c)
#define WIDECHAR(a) a
#endif

/*
**	TYPES
*/

/*
**	VARIABLES
*/
UCO_EXTERN  int	RISuco_debug	UCO_INIT(0);
#if defined(WIN32)
UCO_EXTERN  wchar_t         *RISwide_ptr;
UCO_EXTERN  int             RISwide_size    UCO_INIT(0);
UCO_EXTERN  char            *RISmulti_ptr;
UCO_EXTERN  int             RISmulti_size   UCO_INIT(0);
#endif
