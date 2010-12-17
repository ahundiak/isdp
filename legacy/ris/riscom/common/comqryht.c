/* Do not alter this SPC information: $Revision: 1.1.55.1 $ */
/*
**	NAME:							comqryht.c
**	AUTHORS:						Dave Buehmann
**	CREATION DATE:					2/88
**	ABSTRACT:
**		Given a query pointer and the offset of the error,
**		Print the query and a pointer('^') to the error
**		 into a buffer and return the buffer.
**	
**	REVISION HISTORY:
*/
 
/*
**	INCLUDES
*/

/*
**	DEFINES
*/

/*
**	VARIABLES
*/
#define LINE_LEN	70

/*
#define BUF_LEN		(80*30)
 static  char buf[BUF_LEN]; 
*/

/*
**	FUNCTIONS
*/

/*
**      FUNCTION PROTOTYPES
*/
#define comqryht_c
#include "comqryht.prt"
#include "sys.prt"




extern void RIScom_query_hat(
	char *query,
	int	pos,
	char *bufp)
{
	int i;
	char *cp;

	if (!query || !*query) return;

	strcpy(bufp, "*\n*  ");
	
	/* keep printing until end of the query found */
	for (i = 0, cp = query; *cp; ++cp, ++i)
	{
		bufp += strlen(bufp);

		/* if you find a tab, replace it with a space, else print the char */
		if (*cp == '\t' || *cp == '\n') *bufp++ = ' ';
		else *bufp++ = *cp;
		*bufp = '\0';

		/* check if line ended */
		if (i == LINE_LEN || !*(cp+1))
		{
			strcat(bufp, "\n*  ");

			/* print out error if on this line */
			if (pos && (pos - 1 <= cp - query || !*(cp+1)))
			{
				--pos;
				for (pos %= (LINE_LEN+1); pos; --pos) strcat(bufp, " ");
				strcat(bufp, "^\n");
				if (!*(cp+1)) return;
				else strcat(bufp, "*  ");
				pos = 0;
			}
 			i = -1;
		}
	}

	strcat(bufp, "\n");
	return;
}
