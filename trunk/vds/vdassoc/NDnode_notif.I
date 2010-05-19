/* $Id: NDnode_notif.I,v 1.1.1.1 2001/01/04 21:07:41 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:	vdassoc/NDnode_notif.I
 *
 * Description:
 *		Disconnect and connect result in problems, when the 
 *		channal is not deleted.
 * 		The WARNING will be commented out with OMVERBOSE_WARNING.
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: NDnode_notif.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:41  cvs
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
# Revision 1.1  1996/01/24  20:05:14  pinnacle
# Created: ./vdassoc/NDnode_notif.I by azuurhou for vds.240
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 * 	01/24/96	adz		creation date
 *
 ***************************************************************************/

class implementation NDnode;

#include "AS_status.h"
#include "OMerrordef.h"
#include "OMmacros.h"
#include "nddef.h"
#include "ndmacros.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "dpmacros.h"
#include "godef.h"
#include "godef.h"
#include "igrdp.h"
#include "go.h"
#include "batch.h"
#define AS_DEBUG

method NDnotify_connect(struct GRid new_connected)
{
	IGRlong		status;
	extern struct ext_list NDdelete;
	struct GRid	my_grid;
	IGRint		index;
	IGRchar		my_state;

	status =
	om$send(msg = message NDnode.NDget_state(&my_state),
		targetid = my_id);
	as$status();
 
/* 
   remove the element from delete batch if it is there and print
   a warning message 
*/

	if( my_state & ND_DEL_NO_CH || my_state & ND_DONT_MVRT ){

	  my_grid.objid = my_id;
	  my_grid.osnum = OM_Gw_current_OS;

	  index = NDin_buffer(my_grid,&NDdelete);
	  if( index>=0 ){

#ifdef	vdsDEBUG
    printf
   ("WARNING connection to the element %d %d. This element is support only \n",
     my_id,OM_Gw_current_OS);
  printf("and could have been already deleted after children or parent disconnection\n");
#endif

	    NDdelete.list_id[index].objid = NULL_OBJID;
	  }
	}
 
	return(OM_S_SUCCESS);
}

end implementation NDnode;
