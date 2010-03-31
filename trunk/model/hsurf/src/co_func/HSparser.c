
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:35 $
$Locker:  $
*/

/*#include "hsurf_import.h"*/
#include "igrtypedef.h"
#include "hskyoptypes.h"

#include <stdio.h>
#include <math.h>

#include "wl.h"

#include "OMminimum.h"
#include "igetypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "gr.h"

#include "hsanimate.h"
#include "HSrle.h"
#include "HSsara.h"

#include "HSpr_co_func.h"

/*
 *  Prototype declaration for static functions
 */


#if defined (__) 
#undef __
#endif

#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* HSparser.c */
static void golow __((char *t));
static int strmncmp __((char *s, char *t, int len));

#if defined(__cplusplus)
}
#endif


#undef __



#define	NO_MATCH	0
#define	AMBIGUOUS_STR	0

/*extern	int	strlen();*/
/*static int strmncmp();*/

/*--- golow ------------------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	static	void	golow( char *t )
#else
	static	void	golow(t)

	char	*t;
#endif

{
	int	i;
	
	i=0;
	while (t[i] != '\0')
	{
		if ((t[i] >= 0x41) && (t[i] <= 0x5a))
			t[i] |= 0x60;
		i++;
	}
}

/* --- HSparse_command_option -------------------------------------------- */

/* ABSTRACT:
	This function returns an integer identifying an hsurf command
	option selected by an operator without the use of a form. The 
	input is the string keyed in by the user to select a particular 
	command option, along with a representation of the set of options
	available for the command. As a parser, it is very simple and very
	dependant upon the C language data structures making up its 
	narrow domain of knowledge. A good portion of the parsing of an
	hsurf keyin command goes on in the command object HSkeyin. The
	parser here is controlled by the command object, which may call it
	a number of times in sequence, to identify and validate subportions
	of the keyin command.

   HISTORY:
   	6/09/89			Created.		Mitch Giesy
*/
   	
#if defined(__STDC__) || defined(__cplusplus)
	int	HSparse_command_option( char *s,
			   struct option_set *set )
#else
	int	HSparse_command_option(s, set)
	char			*s;
	struct option_set	*set;
#endif

{
	int		mid,low,high,i,len,ret;
	int		mid_pre,mid_fol;
	struct bs_tree	*S, *member_S;
	   
	/* force keyin string to lower case */
	golow(s);
	
	S = set->bstree_ptr;	

	/*
	   Look for matches scanning only the portion of the
	   user input string that is necessary to establish its unique 
	   match in the set of options. A binary search is used if the
	   option set is large enough, otherwise sequential searching
	   is performed. This parser handles strings that are sequences
	   of space-separated substrings, including the degenerate case 
	   of only one such substring, which equals the string.
	*/

	len = strlen(s);
	   
	if (set->size > 12)
	/* do a binary search, again, if size warrants */
	{
		low = 0;
		high = set->size - 1;
		mid = (low+high)/2;
		member_S = &S[mid];
	
		while (low <= high)
		{
			ret = strmncmp(s, member_S->option, len);
			if (ret == 0)
			{
				if (mid == 0) mid_pre = mid + 1;
					else mid_pre = mid - 1;
				if (mid == set->size - 1) mid_fol = mid - 1;
					else mid_fol = mid + 1;
				if (((ret = strmncmp(s, S[mid_pre].option, len)) == 0) ||
				    ((ret = strmncmp(s, S[mid_fol].option, len)) == 0))
					return(AMBIGUOUS_STR);
				else
					return(member_S->idn);
			}
			else 
 				if (ret < 0)
				{
					high = mid - 1;
					mid = (low + high)/2;
					member_S = &S[mid];
				}
				else
				{
					low = mid + 1;
					mid = (low + high)/2;
					member_S = &S[mid];
				}
		}
	}

	else 
	{

	/* do sequential search */

		for(i=0; i < set->size; i++)
		{
			/* watch out for bounds of s and S[i].option */
			ret = strmncmp(s, S[i].option, len);
			if (ret == 0)
				/* check for ambiguous string */
				if (i < set->size - 1) {
					if ((ret = strmncmp(s, S[i+1].option, len)) == 0)
						return(AMBIGUOUS_STR);
					else return(S[i].idn);
				}
				else
					return(S[i].idn);
		}
	}
	/* no match found if still here */
	return(NO_MATCH);
}

		
/*---strmncmp-----------------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	static	int	strmncmp( char *s,
				  char *t,
				   int len )
#else
	static	int	strmncmp(s, t, len)

	char	*s,*t;
	int	len;
#endif

/*
	The function strmncmp compares s, a [most likely] abbreviated version
	of a string of space-separated alpha characters, t, and returns a zero
	if there is a match, -1 if t > s and one if s > t.
*/

{
	int	j,k;
	char	*temps, *tempt;	

	j = 0;
	temps = s;
	tempt = t;
	do
	{
		k = 0;
		while ((*temps) && (*tempt) && (*temps++ == *tempt++))
			k++;
		j += k;

		if (k > 0)
		{
			/* if a blank is found, find corresponding blank
			   in option set entry */
			if (*(temps-1) == ' ')	
			{
				while((*tempt) && (*tempt++ != ' '))
					;
				if (*tempt) j++;
				else return(1);
			}
			else
			/* check for same number of blank separated character
			   strings in the user-supplied option as in the option
			   set member */
			{
				while((*tempt) && (*tempt++ != ' '))
					;
				if (*tempt) return(-1);
			}
		}
					
									
	} while ((*(temps-1) == ' ') && (*(tempt-1) == ' '));

	if (j == len) return(0);
	if (*--temps < *--tempt)
		return(-1);
	else 	return(1);
}
