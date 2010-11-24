/* Do not alter this PINNACLE information: $Revision: 1.3.28.1 $ */
/*
**	NAME:							comstcmi.c
**	AUTHORS:						Terry McIntyre
**	CREATION DATE:					1/91
**	ABSTRACT:
**		
**	
**	REVISION HISTORY:
**
**		11/94:	Changed the routines to handle multibyte characters.  This was
**				added for INTERNATIONALIZATION support. Paula
*/

#include <ctype.h>
#include "riscom.h"
#include "riscom_macro.h"
#include "rismem.h"
#include "risdebug.h"

/*
**	RIScom_strcmp_ic()
**
**	This routine is the same as strcmp(3C), except it ignores case.
**
**	Input Arguments:
**
**		s1 - string 1
**		s2 - string 2
**
**	Output:
**
**		The same as strcmp(3C) 
*/

extern int RIScom_strcmp_ic(
	char *s1,
	char *s2)
{

#ifdef WIN32
        wchar_t *tmp_s1;
        wchar_t *tmp_s2;
        wint_t  c1;
        wint_t  c2;
	wint_t  ret;
	
        /* sending 0 to indicate null terminated string */

        RIScom_multiwide ( &RISwide_ptr, &s1, &RISwide_size, MULTITOWIDE, 0 );
        RIScom_multiwide ( &RISwide_ptr2, &s2, &RISwide_size2, MULTITOWIDE, 0 );	

        tmp_s1 = RISwide_ptr;
        tmp_s2 = RISwide_ptr2;
#else
	int     ret;
	int     c1;
	int     c2;
	char    *tmp_s1 = s1;
	char    *tmp_s2 = s2;
#endif

	while(1)
	{
           	if (ISUPPER(*tmp_s1))
		{
			c1 = TOLOWER(*tmp_s1);
		}
		else
		{
			c1 = *tmp_s1;
		}

		if (ISUPPER(*tmp_s2))
		{
			c2 = TOLOWER(*tmp_s2);
		}
		else
		{
			c2 = *tmp_s2;
		}

		if ((ret = c1 - c2) != 0)
		{
			break;
		}
		if (*tmp_s1 == 0) /* which implies *tmp_s2 == 0 */
		{
			break;
		}
		tmp_s1++;
		tmp_s2++;
	}
	return ((int)ret);	
}


/*
**	RIScom_strncmp_ic()
**
**	This routine is the same as strncmp(3C), except it ignores case.
**
**	Input Arguments:
**
**		s1 - string 1
**		s2 - string 2
**		n  - number of characters
**
**	Output:
**
**		The same as strncmp(3C) 
*/

extern int RIScom_strncmp_ic(
	char *s1,
	char *s2,
	int n)
{
	int i;

#ifdef WIN32
	wchar_t *tmp_s1;
	wchar_t *tmp_s2;
	wint_t  c1;
	wint_t  c2;
	wint_t  ret = 0; /* needed if n == 0 */
	
	/* send number of characters  - indicating non-null terminated */

	RIScom_multiwide ( &RISwide_ptr, &s1, &RISwide_size, MULTITOWIDE, n ); 
	RIScom_multiwide ( &RISwide_ptr2, &s2, &RISwide_size2, MULTITOWIDE, n ); 	

	tmp_s1 = RISwide_ptr;
	tmp_s2 = RISwide_ptr2;
#else
	int     c1;
	int     c2;
	int     ret = 0;	/* needed if n == 0 */
	char    *tmp_s1 = s1;
	char    *tmp_s2 = s2;
#endif

	for (i = 0; i < n; i++)
	{
		if (ISUPPER(*tmp_s1))
		{
			c1 = TOLOWER(*tmp_s1);
		}
		else
		{
			c1 = *tmp_s1;
		}

		if (ISUPPER(*tmp_s2))
		{
			c2 = TOLOWER(*tmp_s2);
		}
		else
		{
			c2 = *tmp_s2;
		}
		if ((ret = c1 - c2) != 0)
		{
			break;
		}
		if (*tmp_s1 == 0) /* which implies *tmp_s2 == 0 */
		{
			break;
		}
		tmp_s1++;
		tmp_s2++;
	}

    return((int)ret);
}


