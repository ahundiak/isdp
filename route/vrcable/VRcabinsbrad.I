/* $Id: VRcabinsbrad.I,v 1.1.1.1 2001/01/04 21:12:40 cvs Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrcable / VRcabinsbrad.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRcabinsbrad.I,v $
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
# Revision 1.2  1996/01/16  20:13:42  pinnacle
# Replaced: vrcable/VRcabinsbrad.I for:  by r240_int for route240
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

method VRCbInsBendRad(IGRlong *msg; IGRint index )
{
IGRlong 	status;
IGRshort	bt_size, new_size;
IGRint		i;

  /* initialize variables  */
  status = OM_S_SUCCESS;
  *msg = MSSUCC;

  /* set size of bend_table */
  bt_size = om$dimension_of( varray = me->bend_table );

  /*^ 
    printf(" index    : %d \n", index );
    printf(" bt_size  : %d \n", bt_size );
    for( i=0;i<bt_size;i++)
	printf(" bend_tab[%d] : %f \n", i, me->bend_table[i] );
   */

  if( index < 0 || index > bt_size ){
    /*" index: %d not valid\n", index */
    printf(" VRcable.VRCbInsBendRad : index: %d not valid\n", index );
    *msg = MSFAIL;
    return( OM_E_ABORT );
  }

  new_size = bt_size + 1;
  status = om$vla_set_dimension( varray = me->bend_table,
				 size   = new_size );

  if( index == bt_size ){
    /*| add at end bend_table */
    me->bend_table[index] = me->bend_radius;
  }
  else{
    for( i=bt_size; i>index; i--)
      me->bend_table[i] = me->bend_table[i-1];

    me->bend_table[index] = me->bend_radius;
  }
  /*^ 
    for( i=0;i<new_size;i++)
	printf(" new_bend_tab[%d] : %f \n", i, me->bend_table[i] );
   */


  return(status);

}

end implementation VRcable;
