/* $Id: VRcabdelbrad.I,v 1.1.1.1 2001/01/04 21:12:40 cvs Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrcable / VRcabdelbrad.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRcabdelbrad.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:12:40  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/07/17  18:30:54  pinnacle
# route 2.5
#
# Revision 1.1  1996/07/25  18:25:44  pinnacle
# Creation of Route 241 project
#
# Revision 1.2  1996/01/16  20:05:40  pinnacle
# Replaced: vrcable/VRcabdelbrad.I for:  by r240_int for route240
#
 *
 * History:
 *	MM/DD/YY   AUTHOR	DESCRIPTION
 *
 *************************************************************************/


class implementation VRcable;

#include "OMmacros.h"
#include "OMprimitives.h"
#include "msdef.h"
#include "gocmacros.h"
#include "godef.h"
#include "asdef.h"
#include "asbox.h"
#include "mapriv.h"
#include "AS_status.h"

extern	  som_vla_set_dimension();

#define	AS_DEBUG	1

method VRCbDelBendRad( IGRlong *msg; IGRint index )
{
IGRlong		status;		/* return status for method	*/
IGRlong		bt_size, new_size;
IGRint		i;

  /* initialize variables */
  status = OM_S_SUCCESS;
  *msg   = MSSUCC;

  /* determine the bend table size */
  bt_size = om$dimension_of( varray = me->bend_table );

  /*^
    printf(" bt_size  : %d \n", bt_size );
    printf(" contents bend_table \n");
    for( i=0;i<bt_size;i++)
	printf(" bend_tab[%d] : %f \n", i, me->bend_table[i] );
   */

  if( index < 0 || index >= bt_size ){
    /*" invalid index value: %d.\n", index */
    printf(" VRcable.VRCbDelBendRad : invalid index value : %d \n", index );
    *msg = MSFAIL;
    status = OM_E_ABORT;
    goto wrapup;
  }

  new_size = bt_size - 1;

  /* reset the values */
  for( i=index; i<new_size; i++)
    me->bend_table[i] = me->bend_table[i+1];

  /*| reduce the bend_table */
  status = om$vla_set_dimension(varray = me->bend_table,
				size   = new_size );
  as$status(action = RET_STATUS );

  /*^
    printf(" new_size  : %d \n", new_size );
    printf(" contents bend_table \n");
    for( i=0;i<new_size;i++)
	printf(" bend_tab[%d] : %f \n", i, me->bend_table[i] );
  */

wrapup:

  return(status);
}
end implementation VRcable;
