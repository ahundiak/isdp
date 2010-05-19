/* $Id: GRgrchgname.I,v 1.1 2001/01/18 19:09:06 ramarao Exp $  */
/***************************************************************************
 * I/VDS
 *
 * File:        vdassoc/GRgrchgname.I
 *
 * Description:
 *              Duplicate element names 
 *
 * Dependencies:
 *              GRNUCSRC/src/go/graphics/
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *      05/15/00        Jayadev         changes for CR179901429
 *      07/26/00        Jayadev         etl#2913
 ***************************************************************************/

/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME:	GRgraphics
     METHOD NAME:	GRchgname

     Abstract: This routine changes the name of the object.

-----
%SC%    
	GRchgname(msg,struct GRmd_env *env,name)

-----
%EN%
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   ------------------------------------
-----
%EX%
     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
      *msg	   IGRlong	 completion code
				    MSSUCC - successful completion
				    GR_E_INV_REQUEST - duplicate name
				    MSFAIL - error occurred
      *env    struct GRmd_env 	 module environment information
      name	   GRname	 new name of the object
-----
%MD%

     MODULES AND METHODS INVOKED:
     Modules:
	none.

     Methods:
	none.
-----
%RL%

     RELATIONS REFERENCED:
	none.
-----
%NB%

     NOTES:
	none.
-----
%CH%

     CHANGE HISTORY:
	
	MAS     03/27/86 : Design date.
	AIC	07/04/91 : Moved from GRvg to GRgraphics.
-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------
	This routine changes the name of the object.
----*/
/*EH*/

class implementation GRgraphics;

#include "grimport.h"
#include "msdef.h"
#include "OMmacros.h"
#include "godef.h"
#include "grerr.h"
#include "gocmacros.h"
#include "DIdef.h"
#include "DItypedef.h"
#include "DIprims.h"
#include "DIglob.h"

extern IGRint getNewName();

method GRchgname(IGRlong *msg; struct GRmd_env *env;GRname name)
{
  	IGRlong OMmsg, status;
	IGRint ret_type=FALSE;
  	DIobjid    objid;
  	DIspacenum osnum;
	GRname old_name;
  	char current_dir[DI_PATH_MAX];
  	char full_name[DI_PATH_MAX];
  	char mesg[DI_PATH_MAX];

	*msg = MSSUCC;
	OMmsg = OM_S_SUCCESS;

	status = di$untranslate(objname = old_name,
			objid = my_id);

	if(name == NULL) goto rename_old; //etl#2913 

        /* check for duplicate naming CR179901429*/
    	
	di$pwd(dirname = current_dir);
    	sprintf(full_name,"%s:%s",current_dir,name);
    	if(di$translate ( objname = full_name, p_objid = &objid, p_osnum = &osnum ) == DIR_S_SUCCESS)
        {
          ret_type = getNewName(name,current_dir,name);
          /* if(!ret_type) break;  failed, exit and retain old_name */
          if(!ret_type){
          	sprintf(mesg,"Duplicate %s ;Object not named",full_name);
          	UI_status(mesg);
          	sleep(2);
	  	return OMmsg;
	  } 
          sprintf(mesg,"Duplicate %s -> New name %s",full_name,name);
          UI_status(mesg);
          sleep(2);

        } /* check complete */

rename_old:
	if (status == DIR_S_SUCCESS)
	{
	   status = di$rename(oldname = old_name,
		newname = name);
	
	    if (status == DIR_E_NAME_DUP)
	    {
		*msg = GR_E_INV_REQUEST;
		OMmsg = OM_E_ABORT;
	    }
	    else if ( status != DIR_S_SUCCESS)
	    {
		*msg =  MSFAIL;
		OMmsg = OM_E_ABORT;
	    }
	}
	else			/* name not found		*/
	{
	    status = di$add_name(objname = name,
			objid = my_id);
	    if (status == DIR_E_NAME_DUP)
	    {
		*msg = GR_E_INV_REQUEST;
		OMmsg = OM_E_ABORT;
	    }
	    else if (! ( 1 & status))
	    {
		*msg = MSFAIL;
		OMmsg = OM_E_ABORT;
	    }
	}

	GR_NOTIFY_LISTENERS(msg,&OMmsg,GR_ATTR_MODIFIED);
       
	return(OMmsg);
}

end implementation GRgraphics;
