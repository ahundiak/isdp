/*\
Name
	GRgetobjinfo - returns specific object information

Synopsis
	GRgetobjinfo(msg,info)

	IGRlong *msg		Completion code
	struct GRobj_info *info	structure for information about 
				 the object

Description

	This routine retrieves the filename of the reference file
	attachment object and stores it in the input structure.

Diagnostics
	The possible return codes values in the msg field are:

	MSSUCC - successful completion
	MSFAIL - error
Notes
	None.
History
	10/21/86:MAS:Design date.
	01/03/93:Carlos M. Diaz:Compliance with message system and
		changed the way the name is truncated. 
\*/

class implementation GRreffile;

#include <string.h>
#include "grimport.h"
#include "msdef.h"
#include "OMmacros.h"
#include "godef.h"
#include "gocmacros.h"
#include "grmsg.h"
#include "msmacros.h"

#define REF_STRLEN 12			/* length of fixed string	*/
#define OBJINFO_LEN 29			/* number of characters
					   allowed in info structure	*/

void truncate_path ( char *path, int limit )
/*
 * This function makes sure that path fits into limit characters. If it is not the
 * case then the path is truncated in the front.
 */
{
  int  len = strlen ( path );
  char *ptr, tmp [DI_PATH_MAX];
  
  if (len > limit)
  {
    strncpy ( tmp, path, DI_PATH_MAX ) [DI_PATH_MAX - 1] = '\0';
    for (ptr = &tmp [len - limit + 3]; *ptr && *ptr != '/'; ptr++);
    strcat ( strcpy ( path, "..." ), ptr );
  }
}

method GRgetobjinfo(IGRlong *msg; struct GRobj_info *info)
{
	IGRlong	OMmsg;
    	IGRlong dimension;

	OMmsg = OM_S_SUCCESS;		/* initialize to success */	
	*msg = MSSUCC;
        
        dimension = om$dimension_of(varray = me->filename);

	if (dimension)
	{   
	    if (dimension < OBJINFO_LEN)
	    {
	        strcpy(info->type,me->filename);

		if ( (dimension + REF_STRLEN) < OBJINFO_LEN)
		{
	    	    strcat(info->type,", Ref. file");
		}
	    }
	    else
	    {
  	      char tmp [DI_PATH_MAX];

	      strncpy ( tmp, me->filename, DI_PATH_MAX - 1 ) [DI_PATH_MAX - 1] = '\0';
	      truncate_path ( tmp, OBJINFO_LEN );
	      strncpy ( info->type, tmp, OBJINFO_LEN ) [OBJINFO_LEN] = '\0';
	    }
	}
	else
	{
	    ex$message ( msgnumb = GR_I_ReferenceWindow, buff = info->type );
	    /* strcpy(info->type,"Reference window"); */
	}

	return(OM_S_SUCCESS);
}
end implementation GRreffile;

