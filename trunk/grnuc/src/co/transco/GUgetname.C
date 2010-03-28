/* #######################    APOGEE COMPILED   ######################## */
/*
   IGDS element name translation:

   This subroutine searches an IGDS element for user data linkages with
   the u-bit set that have a user_id of GU_LINKAGE_ID and a user type of
   GU_NAME_TYPE.

   If above values are found then the user data is copied into the output
   variable 'name'.

*/

/*
#include 	"coimport.h"
*/
#include	"OMminimum.h"
#include	"igrtypedef.h"
#include	"igr.h"
#include	"transmacros.h"
#include	"transdef.h"
#include	"translate.h"
#include	"msdef.h"
#include	"OMmacros.h"


 IGRboolean GUgetname(msg,element,name)


 IGRlong *msg;		/* output - completion code
				    MSSUCC - success
				    MSFAIL - bad ele	*/
 IGRchar *element;	/* input - IGDS element	ptr	*/
 IGRchar *name;		/* output - element name	*/


 {
	IGRshort   *ptr;
	IGRshort   *end_of_ele;
	struct	   GUcommon_header_info *ele;
	struct	   GUlinkage *linkage;
	int	   i;
	IGRboolean has_name = FALSE;	/* output - TRUE if found name	*/
					/*	    FALSE otherwise	*/

	ele = (struct GUcommon_header_info *) element;
	end_of_ele = (IGRshort *) &ele->words_to_follow +
			ele->words_to_follow;
	ptr = (IGRshort *) &ele->index_to_ae +
	      ele->index_to_ae + 1;

	while (ptr <= end_of_ele)
	{
 	  linkage = (struct GUlinkage *) ptr;
	  if (linkage->header.properties & GU_LINKAGE_PROPS)
	  {
	   if (linkage->header.user_id == GU_LINKAGE_ID)
	   {
 	    if (linkage->type == GU_NAME_TYPE)
	    {
 	    	has_name = TRUE;
		i = ((linkage->header.words_to_follow - 1) * 2) - 1;
		blkmv( i, (IGRchar *) &linkage->data, name );
		name[i] = '\0';
 		break;
	    }
	   }
	  }
	  ptr += (1 + linkage->header.words_to_follow);
    	  *msg = MSSUCC;
  	}
	return( has_name );
}
