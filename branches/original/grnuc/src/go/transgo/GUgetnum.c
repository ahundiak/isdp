/* #######################    APOGEE COMPILED   ######################## */
#include "grimport.h"
#include "igrtypedef.h"
#include "igr.h"

IGRboolean GUget_numeral (input_string, num)


IGRchar 	*input_string;
IGRshort	*num;

{

IGRint 		i;
IGRchar		temp_string[100];
IGRboolean	found = FALSE;
IGRboolean	retcode = FALSE;

/*
extern int 	strlen();
extern int 	sscanf();
*/
extern char 	*strcpy();


	i = strlen (input_string) - 1;
	while ( i >= 0 && !found )
	{
	   if ((input_string[i] >= '0') && (input_string[i] <= '9'))
	   {
		found = TRUE;
	   }
	   else 
	   {
		i--;
	   }
	}

	if ( found )
	{
	   input_string[i+1] = '\0';
	   while ( i >= 0 && found )
	   {
		if ((input_string[i] >= '0') && (input_string[i] <= '9'))
		{
		    i--;
		}
		else 
		{
		    found = FALSE;
		}
	   }
	   strcpy ( temp_string, &(input_string[i+1]));
	   sscanf ( temp_string, "%hd", num);
	   retcode = TRUE;
	}
	return (retcode);
}
