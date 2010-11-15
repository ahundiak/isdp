/* Do not alter this PINNACLE information: $Revision: 1.2.28.1 $ */
/*
**	NAME:							compd.c
**	AUTHORS:						Dave Buehmann
**	CREATION DATE:					1/89
**	ABSTRACT:
**		
**	
**	REVISION HISTORY:
**    9/91 - dvk
**      Everything in here was based on 24 characters and 5 keys;
**      there were some 0-4 range assumptions;
**		I have made RIS_PD_KEYS a defined token.       
**      I also just generally changed things to be more generic; 
**		This routine currently handles passwords of 31 characters
**      (RIS_MAX_ID_SIZE-1), with 6 keys, and so has a 38 character
**      encryption size (31+6+null).  It might work generically within
**      a small range of RIS_MAX_ID_SIZE, but this routine
**      was not generic in the past and still might not be.
**      It has only been verified with its current settings.
**
**	  2/93 - tdm
**		Made these calls more generic by making the number of keys a
**		parameter.  RIS_PD_KEYS now represents the maximum number of keys.
**		
*/
 
/*
**	INCLUDES
*/
#include "rislimit.h"
#include "ris_err.h"
#include "risdebug.h"
#include "risstjmp.h"

/*
**	DEFINES
*/
#if defined(WIN32) || defined(DOS)
# define RAND()   (rand() % 0x7FFF)
#endif
#if defined(unix) || defined(vms)
# define RAND()   (rand())
#endif
#ifdef COM_DBG
#undef COM_DBG
#endif

#ifdef TESTING

#ifdef INTERACTIVE
#define COM_ERR(n)	printf("n\n")
#define COM_DBG(arg) printf arg
#else
#define COM_ERR(n)	printf("n\n")
#define COM_DBG(arg)
#endif

#else

/* remove debug code unless testing */
#define COM_ERR(err)												\
{																	\
	COM_DBG(("Error 0x%x in RIS_crypt; line %d\n", err, __LINE__));	\
	LONGJMP(err);													\
}
#define COM_DBG(s)
#endif

#define FIRST_CHAR	'!'
#define LAST_CHAR	'~'

/*
**	TYPES
*/

/*
**	FUNCTION PROTOTYPES
*/
#define compd_c
#include "compd.prt"
#include "comjmp.prt"
#include "sys.prt"

/*
**	VARIABLES
*/

/*
**	FUNCTIONS
*/

/**************************************************************************/

	/*
	** Encrypt something (max input length 31 characters).
	** 
	** We can pass in the same pointer as input and output without problems.
	*/ 

static void com_pd(
	char *pd,
	char *crpt,
	int	 num_keys)
{
	int range, i, j, k, len, key[RIS_PD_KEYS], keyval;
	char str[RIS_MAX_ID_SIZE];
	char cpt[RIS_MAX_ID_SIZE*2];
	char c;

	COM_DBG(("RIScom_pd(pd:<%s> num_keys:%d)\n", STRING(pd), num_keys));

	if (num_keys < 1 || num_keys > RIS_PD_KEYS)
	{
		COM_ERR(RIS_E_ENCRYPTION_ERROR);
	}

	if (!*pd)
	{
		*crpt = 0;
		return;
	}

	/* range = total number of printable (storable) characters */
	range = LAST_CHAR - FIRST_CHAR + 1;
	len = RIS_MAX_ID_SIZE-1;

	/* make a copy of the string */
	strcpy(str, pd);
	i = strlen(str);
	if (i > RIS_MAX_ID_SIZE-1)
	{
		COM_ERR(RIS_E_ENCRYPTION_ERROR);
	}

	COM_DBG(("RIScom_pd: str:<%s>\n", str));

	/* set the null to '!' and any garb past end of string to known values */
	str[i++] = '!';
	for ( ; i < len; ++i) str[i] = (char)('~' - i);
	str[i] = '\0';

	COM_DBG(("RIScom_pd: str:<%s>\n", str));

	/* calculate num_keys keys */
	for (i=0; i<num_keys; ++i)
	{	
		key[i] = (str[i] + time(0) + RAND()) % range;
		COM_DBG(("RIScom_pd: key[%d]: %d\n", i, key[i]));
	}

	/* encrypt each character */
	keyval = 0;	/* shut up compiler */
	for (i=0; i<len; ++i)
	{
		{
			int j = 0;
			int k = i/num_keys;
			for (keyval = 0; j < k; ++j)
			{
				keyval += key[j];
			}
			keyval += key[i%num_keys];
			keyval = keyval % range;
		}
		str[i] = (char)(((str[i] - FIRST_CHAR + keyval) % range) + FIRST_CHAR);
	}

	COM_DBG(("RIScom_pd: after encrpt str:<%s>\n", str));

	/* reverse the string */
	for (i=0; i<len/2; ++i)
	{
		c = str[i];
		str[i] = str[len-1-i];
		str[len-1-i] = c;
	}

	COM_DBG(("RIScom_pd: after reverse str:<%s>\n", str));

	/* put each key into the character set */
	for (i=0; i<num_keys; ++i)
	{
		key[i] += FIRST_CHAR;
	}

	/*
	**	the encrypted string will be num_keys characters longer than the
	**	password, with a key element stored every num_keys character.
	*/

	i=0;
	j=0;
	k=0;
	while (i<len)
	{
		if ((k < num_keys) && (j%num_keys == 0)) cpt[j++] = (char)(key[k++]);
		else cpt[j++] = str[i++];
	}
	cpt[j] = '\0';

	COM_DBG(("RIScom_pd: after scramble cpt:<%s> i:%d j:%d k:%d\n",cpt,i,j,k));

	if ((int)strlen(cpt) != (RIS_MAX_ID_SIZE - 1) + num_keys)
	{
		COM_DBG(("strlen(cpt:<%s>):%d\n", crpt, strlen(crpt)));
		COM_ERR(RIS_E_ENCRYPTION_ERROR);
	}

	strcpy(crpt, cpt);
}

/**************************************************************************/

	/*
	** Routine to decrypt an encrypted password.
	**
	** Note that it is acceptable to pass in the same pointer twice.
	** (You do not need two separate buffers.)
	*/

static void com_depd(
	char *crpt,
	char *decrpt,
	int num_keys)
{
	int range, i, j, k, len, key[RIS_PD_KEYS], keyval;
	char str[RIS_MAX_ID_SIZE];
	char cpt[RIS_MAX_ID_SIZE*2];
	char c;

	COM_DBG(("RIScom_depd(crpt:<%s>, num_keys:%d)\n", crpt, num_keys));

	if (num_keys < 1 || num_keys > RIS_PD_KEYS)
	{
		COM_ERR(RIS_E_ENCRYPTION_ERROR);
	}

	if (!*crpt)
	{
		*decrpt = 0;
		return;
	}

	/*
	** The length must be exactly what we expect; there is one
	** length that matches RIS 3.0 and beyond (31-character identifiers).
	*/
	if ((int)strlen(crpt) != (RIS_MAX_ID_SIZE - 1) + num_keys)
	{
		COM_DBG(("strlen(crpt:<%s>):%d\n", crpt, strlen(crpt)));
		COM_ERR(RIS_E_DECRYPTION_ERROR);
	}

	len = RIS_MAX_ID_SIZE-1;

	/* range = total number of printable (storable) characters */
	range = LAST_CHAR - FIRST_CHAR + 1;

	/* make a copy of the string */
	strcpy(cpt, crpt);

	COM_DBG(("RIScom_depd: cpt:<%s>\n", cpt));

	/*
	**	the encrypted string will be num_keys characters longer than the
	**	password, with a key element stored every num_keys character.
	*/

	i=0;
	j=0;
	k=0;
	while (i<len)
	{
		if ((k < num_keys) && (j%num_keys == 0)) key[k++] = cpt[j++];
		else str[i++] = cpt[j++];
	}
	str[i] = '\0';

	COM_DBG(("RIScom_depd: after descramble str:<%s> i:%d j:%d k:%d\n",str,i,j,k));

	/* take each key out of the character set */
	for (i=0; i<num_keys; ++i)
	{
		key[i] -= FIRST_CHAR;
		COM_DBG(("RIScom_pd: key[%d]: %d\n", i, key[i]));
	}

	/* (un)reverse the string */
	for (i=0; i<len/2; ++i)
	{
		c = str[i];
		str[i] = str[len-1-i];
		str[len-1-i] = c;
	}

	COM_DBG(("RIScom_depd: after (un)reverse str:<%s>\n", str));

	/* decrypt each character */
	keyval = 0;	/* shut up compiler */
	for (i=0; i<len+1; ++i)
	{
		{
			int j = 0;
			int k = i/num_keys;
			for (keyval = 0; j < k; ++j)
			{
				keyval += key[j];
			}
			keyval += key[i%num_keys];
			keyval = keyval % range;
		}
		str[i] = (char)(str[i] - keyval);
		if (str[i] < FIRST_CHAR) str[i] += range;
	}

	COM_DBG(("RIScom_depd: after decrpt str:<%s>\n", str));

	/* set the '!' to a null */
	for (i=0; str[i] && str[i] != '!' && i < RIS_MAX_ID_SIZE-1; ++i) ;
	str[i] = '\0';

	COM_DBG(("RIScom_depd: str:<%s>\n", str));

	strcpy(decrpt, str);
}

/******************************************************************************/

extern void RIScom_pd(
	char *pd,
	char *crpt)
{
	com_pd(pd, crpt, RIS_PD_KEYS);
}

/******************************************************************************/

extern void RIScom_depd(
	char *crpt,
	char *decrpt)
{
	com_depd(crpt, decrpt, RIS_PD_KEYS);
}

/**************************************************************************/

extern int RIScom_pd_same(
	char *pd,
	char *crpt)
{
	char dcrpt[RIS_MAX_ID_SIZE];
	int i, st;

	COM_DBG(("RIScom_pd_same: pd:<%s> crpt:<%s>\n", pd, crpt));

	/* NULL pass ptr signifies password should be ignored */
	if (!pd) return(1);

	if (!*pd && !*crpt) return(1);

	if (!*crpt) return(0);

	RIScom_depd(crpt, dcrpt);
	st = (strcmp(pd, dcrpt) == 0);

	/* clear out decription */
	for (i=0; i<RIS_MAX_ID_SIZE; ++i) dcrpt[i] = '\0';

	return(st);
}

/**************************************************************************/

extern int RIScom_pdcmp(
	char *crpt1,
	char *crpt2)
{
	char dcrpt1[RIS_MAX_ID_SIZE];
	char dcrpt2[RIS_MAX_ID_SIZE];
	int i, st;

	COM_DBG(("RIScom_pd_same: crpt1:<%s> crpt2:<%s>\n", crpt1, crpt2));

	if (!*crpt1 && !*crpt2) return(0);

	RIScom_depd(crpt1, dcrpt1);
	RIScom_depd(crpt2, dcrpt2);
	st = strcmp(dcrpt1, dcrpt2);

	/* clear out decription */
	for (i=0; i<RIS_MAX_ID_SIZE; ++i) 
	{
		dcrpt1[i] = '\0';
		dcrpt2[i] = '\0';
	}
	return(st);
}

/**************************************************************************/

extern void RIScom_rap_pd(
	char *pd,
	char *crpt)
{
	com_pd(pd, crpt, RIS_PD_KEYS-1);
}

/******************************************************************************/

extern void RIScom_rap_depd(
	char *crpt,
	char *decrpt)
{
	com_depd(crpt, decrpt, RIS_PD_KEYS-1);
}

/**************************************************************************/

#ifdef TESTING

#include <signal.h>

static  char pd[RIS_MAX_ID_SIZE];

extern void hndl()
{
	long t;
	t = time();
	t = ctime(&t);
	printf("alarm at %s; pd: <%s>\n", t, pd);
	alarm(10);
}

main()
{
	char dcpt[RIS_MAX_ID_SIZE];
	char cpt[RIS_MAX_PASSWD_SIZE];
	int i,j,k;

	i=j=k=0;

#ifdef INTERACTIVE
	do
	{
		printf("Enter a password: ");
		fflush(stdout);
		RIScom_gets(pd);

		if (strncmp(pd, "depd", 4) == 0) strcpy(cpt, &pd[5]);
		else
		{
			RIScom_pd(pd, cpt);
			printf("password: <%s>, cpt:<%s>\n\n", pd, cpt);
		}
		RIScom_depd(cpt, dcpt);
		printf("decpt:<%s>\n", dcpt);
	} while (*pd);
#else

#ifdef OLD
	for (j='!'; j<'~'; ++j)
	{
		for (i=0; i<(RIS_MAX_ID_SIZE-1); ++i)
		{
			pd[i] = j;
			pd[i+1] = '\0';

			RIScom_pd(pd, cpt);
			RIScom_depd(cpt, dcpt);
	
			if (strcmp(pd, dcpt) != 0)
			{
				printf("pd:<%s> dcpt:<%s> don't match\n", pd, dcpt);
			}
		}
	}
#endif

	RIScom_sigset(SIGALRM, hndl);
	alarm(10);

	i=0;
	pd[i] = 'a';
	pd[i+1] = '\0';

	while (j >= 0)
	{
		RIScom_pd(pd, cpt);
		RIScom_depd(cpt, dcpt);

		if (strcmp(pd, dcpt) != 0)
		{
			printf("pd:<%s> dcpt:<%s> don't match\n", pd, dcpt);
		}

		pd[j] += RAND() % 13;
		if (pd[j] > 'z')
		{
			for (k=j; k<i; ++k) pd[k] = 'a';

			for ( ; j>=0 && ++pd[j] > 'z'; --j)
			{
				pd[j] = 'a';
			}

			if (j<0)
			{
				int t;
				if (++i > (RIS_MAX_ID_SIZE-1)) return;
				pd[i] = 'a';
				pd[i+1] = '\0';
				t = time(0);
				t = ctime(&t);
				printf("doing pd:<%s> time: %s \n", pd, t);
			}
			j=i;
		}
	}
#endif /* INTERACTIVE */
}
#endif /* TESTING */
