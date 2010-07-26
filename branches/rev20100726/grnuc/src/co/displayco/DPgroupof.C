/* #######################    APOGEE COMPILED   ######################## */
#include <string.h>

#include "msdef.h"
#include "igrtypedef.h"

#include "DPgroupof.h"    /* defining prototype file */
#include "msmacros.h"
#include "grmsg.h"


IGRint DPproc_group_of ( msg, elig_mask, ly_mask, elig_string )

IGRlong *msg;
IGRlong *elig_mask;
IGRlong *ly_mask;
IGRchar *elig_string;

{

IGRshort index;
IGRboolean ly_on;
IGRboolean ly_off;
IGRboolean ly_mix;
IGRlong ly_def_onf; 

*msg = MSSUCC;
		/* Are all the layers on or off ? */
		/* mask of layers defined ANDED with the mask of layers on/off
		   gives the layers defined that are on/off.  If the layers
		   defined is not equal to the layers defined that are on/off
		   then one of the layers that is defined is off; hence 
		   display on/off is ambiguous of mixed for this group. */

index = 0;
ly_on = TRUE;
ly_off = TRUE;
ly_mix = FALSE;

	while ( index < 32 && ly_mix == FALSE)
	{
	    ly_def_onf = ly_mask[index] & elig_mask[index];
	    if (ly_mask[index] == ly_def_onf) 
	    {
		/* all the layers defined are on */
		ly_off = FALSE;
	    }
	    else
	    {
		/* either they are all off or there is a mixture */
		ly_on = FALSE;
		if (ly_def_onf != 0)
		{
		    ly_mix = TRUE;
		}
	    }
	    index++;
	}
	if (ly_mix == TRUE)
	{
		ex$message(msgnumb = GR_I_LayMixed, buff = elig_string);	
	}
	else if (ly_on == TRUE)
	{
		ex$message(msgnumb = GR_I_LayOn, buff = elig_string);
	}
	else /* only other case is for all layers to be off */
	{
		ex$message(msgnumb = GR_I_LayOff, buff = elig_string);
	}

return (1);
}


IGRchar	*COstrp_blnks(token)

  char *token;
{

   char *beg;
   int  len;

 /* strip leading blanks  */

	while ((*token != '\0') && *token == ' ')
	{
	   token++;
	}

	if (*token == '\0')
	{
	   return(0);
	}

	beg = token;

	len = strlen(token);

	token += (len - 1);

  /* strip trailing blanks */

	while (*token == ' ')
	{
	   token--;
	}
	
	*(token + 1) = '\0';

	return(beg);
}
	

 
