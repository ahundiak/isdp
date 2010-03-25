#include "main.h"

int
chkerror(sts, string)

int sts;		/* error number */
char *string;		/* error message */

/*******************************************************************/
/* this procedure prints out an error message for error number num */
/*******************************************************************/

{
	if (sts)
	{
		fprintf(stderr, "Error (%d):  %s\n", sts, string);
		return(TRUE);
	} /* if */

	else
		return(FALSE);

} /* err_message */

