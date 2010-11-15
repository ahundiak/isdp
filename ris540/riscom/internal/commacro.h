/* Do not alter this SPC information: $Revision: 1.1.53.1 $ */

#if defined(WIN32)
#include <wchar.h>

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
#define STRSTR(a,c)         RIScom_wcsstr((wchar_t *) a,(wchar_t *) c)
#define WIDECHAR(a)         L##a

COM_EXTERN  wchar_t         *RISwide_ptr;
COM_EXTERN  wchar_t         *RISwide_ptr2;
COM_EXTERN  char            *RISmulti_ptr;
COM_EXTERN  int             RISmulti_size   COM_INITIAL(0);
COM_EXTERN  int             RISwide_size    COM_INITIAL(0);
COM_EXTERN  int             RISwide_size2    COM_INITIAL(0);

/**********************************************************************/
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
#define STRSTR(a,c)  RIScom_strstr((char *) a, (char *) c)
#define WIDECHAR(a) a
#endif
