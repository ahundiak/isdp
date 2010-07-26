/*
Name
        GUputname

Description
        This subroutine takes the name of an IGDS element name, which was
        extracted from the user data linkage, and puts it in the object info
        data structure.
*/

/*
#include 	"coimport.h"
*/
#include	"OMminimum.h"
#include	"igrtypedef.h"
#include	"igetypedef.h"
#include	"gr.h"
#include	"DIdef.h"
#include	"DItypedef.h"
#include	"igr.h"
#include	"transmacros.h"
#include	"transdef.h"
#include	"translate.h"
#include	"msdef.h"
#include	"OMmacros.h"
#include	"DIprims.h"

#argsused
IGRlong GUputname(msg,name,object_info,env)

IGRlong *msg;		  /* output - completion code		   */
			  /*          MSSUCC - success		   */
			  /*	      MSFAIL - name can't be added */
IGRchar *name;		  /* input - element name		   */
struct GRid *object_info; /* input - object for name		   */
struct GRmd_env *env;	  /* input - environment for object	   */


{
	IGRchar fullname[50];
	IGRlong	status;
	OMuword	osnum = 2;

	status = di$give_pathname ( osnum = osnum,
			 	    pathname = fullname );

	if (!(status & 1))
	{
	   *msg = MSFAIL;
	   goto wrapup;
	}

	strcat (fullname, ":usr");
	strcat (fullname, name );

	status = ( di$mkpath( objid = object_info->objid,
			      pathname = fullname,
			      p_osnum = &osnum  ) );

	if (!(status & 1))
	{
	   *msg = MSFAIL;
	   goto wrapup;
	}

	switch (status)
	{
		case DIR_S_SUCCESS:	*msg = MSSUCC;
					break;
		case DIR_E_NAME_DUP:
		case DIR_E_SYNTAX:
		case DIR_E_ABORT:	*msg = MSFAIL;
					break;
	} /* end switch */

wrapup:
	return(*msg);

}

