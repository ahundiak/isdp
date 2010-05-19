/* $Id: VDget_name.I,v 1.1.1.1 2001/01/04 21:09:32 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdutil / VDget_name.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDget_name.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:09:32  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * -------------------------------------------------------------------*/

/*
ABSTRACT : 
	I/VDS


CHANGE HISTORY
	
     Function vdget_name 
*/

class implementation Root;

#include <math.h>

#include "OMmacros.h"
#include "godef.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "go.h"
#include "AS_status.h"

from	ACpretend	import ACgive_downscan, ACfind_parent;
from	GRvg		import GRgetname;

vdget_name( obj, name )
struct GRid	*obj;
IGRchar 	*name;
{
 struct GRid 	mac;
 IGRint		status;
 IGRlong   	msg;		
 char		getname[DI_PATH_MAX], scan_name[DI_PATH_MAX];
 char		*pt_name, *strrchr();

  if( ! name || ! obj ) {
	if( name )	name[0] = '\0';
	return OM_E_ABORT;
  }

  /*"plane: %d, %d\n", obj->objid, obj->osnum */

  name[0] = '\0';

  status =
  om$send(msg = message ACpretend.ACgive_downscan(scan_name),
	  senderid = NULL_OBJID,
          targetid = obj->objid,
          targetos = obj->osnum);
  if(status&1)
  {
    /*| It is a macro */

    mac.objid = NULL_OBJID;
    status =
    om$send(msg = message ACpretend.ACfind_parent(&mac,NULL,NULL),
 	    senderid = NULL_OBJID,
            targetid = obj->objid,
            targetos = obj->osnum);
    if(status&1 && mac.objid != NULL_OBJID )
    {
      status =
      om$send(msg = message GRvg.GRgetname(&msg,getname),
 	      senderid = NULL_OBJID,
              targetid = mac.objid,
              targetos = mac.osnum);
      if(status&msg&1)
      {
	pt_name = strrchr(getname,':');
        if(pt_name == NULL) strcpy( name , getname );
	else if(scan_name[0] != '\0')
	{
	  /* *pt_name = ' '; */
	  strcat(&pt_name[1],":");
	  strcat(&pt_name[1],scan_name); 
	  strcpy(name,&pt_name[1]);
          /*"macro, get the name: %s:, %s \n", name, &pt_name[1]*/
	}
      }
      else name[0] = '\0';
    }
  }
  else{
    /* It is an regular object */
    status =
    om$send(msg = message GRvg.GRgetname(&msg,getname),
	    senderid = NULL_OBJID,
            targetid = obj->objid,
            targetos = obj->osnum);
    if(status&msg&1){
      /*| Just take the last part of the name */
      pt_name = strrchr(getname,':');
      pt_name = ( pt_name ) ? pt_name+1 : getname ;
      strcpy(name, pt_name );
    }
    else name[0] = '\0'; 
  }

  return OM_S_SUCCESS ;
}

end implementation Root;

